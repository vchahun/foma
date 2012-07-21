cdef class MEDMatch:
    cdef public int cost
    cdef public bytes instring
    cdef public bytes outstring

    def __cinit__(self, int cost, char* instring, char* outstring):
        self.cost = cost
        self.instring = instring
        self.outstring = outstring

    def __str__(self):
        return self.outstring

cdef class FSM:
    cdef fsm* net

    def __cinit__(self, binary=None, text=None):
        if text:
            self.net = fsm_read_text_file(<char *> text)
        elif binary:
            self.net = fsm_read_binary_file(<char *> binary)
        else:
            self.net = fsm_create('')

    def __dealloc__(self):
        if self.net != NULL:
            fsm_destroy(self.net)

    @classmethod
    def frombinary(type cls, char* filename):
        return FSM(binary=filename)

    @classmethod
    def fromtext(type cls, char* filename):
        return FSM(text=filename)

    def write(self, char* filename):
        if fsm_write_binary_file(self.net, filename):
            raise IOError('cannot write FSM to \'%s\'' % filename)

    def apply_up(self, char* word):
        cdef apply_handle* applyh = apply_init(self.net)
        cdef char* result = apply_up(applyh, word)
        while True:
            if result == NULL: break
            yield result
            result = apply_up(applyh, NULL)
        apply_clear(applyh)

    def apply_down(self, char* word):
        cdef apply_handle* applyh = apply_init(self.net)
        cdef char* result = apply_down(applyh, word)
        while True:
            if result == NULL: break
            yield result
            result = apply_down(applyh, NULL)
        apply_clear(applyh)

    def med(self, char* word, int limit=4, int cutoff=15, int heap_max=4194305, char* align=''):
        if not self.arity == 1:
            raise NotImplementedError('miminum edit distance is only supported for FSAs')
        cdef apply_med_handle* medh = apply_med_init(self.net)
        apply_med_set_med_limit(medh, limit)
        apply_med_set_med_cutoff(medh, cutoff)
        apply_med_set_heap_max(medh, heap_max)
        apply_med_set_align_symbol(medh, align)
        cdef char* result = apply_med(medh, word)
        cdef int cost
        cdef char *instring, *outstring
        while True:
            if result == NULL: break
            cost = apply_med_get_cost(medh)
            instring = apply_med_get_instring(medh)
            outstring = apply_med_get_outstring(medh)
            yield MEDMatch(cost, instring, outstring)
            result = apply_med(medh, NULL)

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
