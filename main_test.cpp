#include "libsaki/test/test.h"
#include "libsaki/test/bmark.h"



int main(int argc, char *argv[])
{
    (void) argc;
    (void) argv;

    using namespace saki;
    //saki::testAll();
    Bmark::test(Girl::Id::DOGE);

    return 0;
}
