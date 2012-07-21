cdef extern from "fomalib.h":
    cdef struct fsm:
        int arity
        int arccount
        int statecount
        int linecount
        int finalcount
        long long pathcount
        int is_deterministic
        int is_pruned
        int is_minimized
        int is_epsilon_free
        int is_loop_free
        int is_completed
        int arcs_sorted_in
        int arcs_sorted_out

    ctypedef struct fsm_read_binary_handle:
        pass

    cdef struct apply_handle:
        pass

    cdef struct apply_med_handle:
        pass

    # I/O
    cdef fsm_read_binary_handle fsm_read_binary_file_multiple_init(char *filename)
    cdef fsm *fsm_read_binary_file(char *filename)
    cdef fsm *fsm_read_text_file(char *filename)
    int fsm_write_binary_file(fsm *net, char *filename)
    # Operations
    fsm *fsm_create(char *name)
    cdef void fsm_destroy(fsm *net)
    fsm *fsm_determinize(fsm *net)
    fsm *fsm_minimize(fsm *net)
    # Application
    cdef apply_handle *apply_init(fsm *net)
    cdef void apply_clear(apply_handle *h)
    cdef char* apply_down(apply_handle *h, char* word)
    cdef char* apply_up(apply_handle *h, char* word)
    # MED
    cdef apply_med_handle *apply_med_init(fsm *net)
    char *apply_med(apply_med_handle *medh, char *word)
    void apply_med_set_heap_max(apply_med_handle *medh, int max)
    void apply_med_set_med_limit(apply_med_handle *medh, int max)
    void apply_med_set_med_cutoff(apply_med_handle *medh, int max)
    int apply_med_get_cost(apply_med_handle *medh)
    void apply_med_set_align_symbol(apply_med_handle *medh, char *align)
    char *apply_med_get_instring(apply_med_handle *medh)
    char *apply_med_get_outstring(apply_med_handle *medh)
