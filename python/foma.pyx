from libc.stdlib cimport free

cdef bytes as_str(word):
    if isinstance(word, bytes):
        return word
    elif isinstance(word, unicode):
        return word.encode('utf8')
    raise TypeError('Expected string and not {0}'.format(type(word)))

cdef class MEDMatch:
    cdef public int cost
    cdef public unicode instring
    cdef public unicode outstring

    def __cinit__(self, int cost, bytes instring, bytes outstring):
        self.cost = cost
        self.instring = unicode(instring, 'utf8')
        self.outstring = unicode(outstring, 'utf8')

    def __str__(self):
        return self.outstring

def read_binary(filename):
    return FSM(binary=as_str(filename))

def read_text(filename):
    return FSM(text=as_str(filename))

cdef class FSM:
    cdef fsm* net

    def __cinit__(self, binary=None, text=None):
        if text:
            self.net = fsm_read_text_file(<char *> text)
            if not self.net:
                raise IOError('cannot read text file {0}'.format(text))
        elif binary:
            self.net = fsm_read_binary_file(<char *> binary)
            if not self.net:
                raise IOError('cannot read binary fsm {0}'.format(binary))

    def __dealloc__(self):
        if self.net != NULL:
            fsm_destroy(self.net)

    def write(self, filename):
        if fsm_write_binary_file(self.net, filename):
            raise IOError('cannot write FSM to \'%s\'' % filename)

    def apply_up(self, word):
        word = as_str(word)
        cdef apply_handle* applyh = apply_init(self.net)
        cdef char* result = apply_up(applyh, word)
        try:
            while True:
                if result == NULL: break
                yield unicode(result, 'utf8')
                result = apply_up(applyh, NULL)
        finally: 
            apply_clear(applyh)

    def apply_down(self, word):
        word = as_str(word)
        cdef apply_handle* applyh = apply_init(self.net)
        cdef char* result = apply_down(applyh, word)
        try:
            while True:
                if result == NULL: break
                yield unicode(result, 'utf8')
                result = apply_down(applyh, NULL)
        finally: 
            apply_clear(applyh)

    def med(self, word, int limit=4, int cutoff=15,
            int heap_max=4194305, align=None):
        if not self.arity == 1:
            raise NotImplementedError('miminum edit distance is only supported for FSAs')
        cdef apply_med_handle* medh = apply_med_init(self.net)
        apply_med_set_med_limit(medh, limit)
        apply_med_set_med_cutoff(medh, cutoff)
        apply_med_set_heap_max(medh, heap_max)
        if align:
            align = as_str(align)
            apply_med_set_align_symbol(medh, align)
        word = as_str(word)
        cdef char* result = apply_med(medh, word)
        cdef int cost
        cdef char *instring, *outstring
        try:
            while True:
                if result == NULL: break
                cost = apply_med_get_cost(medh)
                instring = apply_med_get_instring(medh)
                outstring = apply_med_get_outstring(medh)
                yield MEDMatch(cost, instring, outstring)
                result = apply_med(medh, NULL)
        finally: 
            free(medh)

    property arity:
        def __get__(self):
            return self.net.arity

    property deterministic:
        def __get__(self):
            return self.net.is_deterministic

    property pruned:
        def __get__(self):
            return self.net.is_pruned

    property minimized:
        def __get__(self):
            return self.net.is_minimized
    
    property statecount:
        def __get__(self):
            return self.net.statecount

    property arccount:
        def __get__(self):
            return self.net.arccount

    def determinize(self):
        self.net = fsm_determinize(self.net)

    def minimize(self):
        self.net = fsm_minimize(self.net)
