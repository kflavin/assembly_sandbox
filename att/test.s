main:
        pushq   %rbp
        movq    %rsp, %rbp
        subq    $16, %rsp
        movl    std::cin, %edi
        call    std::basic_istream<char, std::char_traits<char> >::get()
        movb    %al, -1(%rbp)
        movsbl  -1(%rbp), %eax
        movl    %eax, %esi
        movl    std::cout, %edi
        call    std::basic_ostream<char, std::char_traits<char> >& std::operator<< <std::char_traits<char> >(std::basic_ostream<char, std::char_traits<char> >&, char)
        movl    $0, %eax
        leave
        ret
__static_initialization_and_destruction_0(int, int):
        pushq   %rbp
        movq    %rsp, %rbp
        subq    $16, %rsp
        movl    %edi, -4(%rbp)
        movl    %esi, -8(%rbp)
        cmpl    $1, -4(%rbp)
        jne     .L3
        cmpl    $65535, -8(%rbp)
        jne     .L3
        movl    std::__ioinit, %edi
        call    std::ios_base::Init::Init()
        movl    $__dso_handle, %edx
        movl    std::__ioinit, %esi
        movl    std::ios_base::Init::~Init(), %edi
        call    __cxa_atexit
.L3:
        leave
        ret
        pushq   %rbp
        movq    %rsp, %rbp
        movl    $65535, %esi
        movl    $1, %edi
        call    __static_initialization_and_destruction_0(int, int)
        popq    %rbp
        ret

