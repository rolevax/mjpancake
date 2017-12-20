#include "p_table_env.h"

#include <QTime>



int PTableEnv::hour24() const
{
    return QTime::currentTime().hour();
}
