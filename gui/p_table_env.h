#ifndef P_TABLE_ENV_H
#define P_TABLE_ENV_H

#include "libsaki/table/table_env.h"



class PTableEnv : public saki::TableEnv
{
public:
    PTableEnv() = default;
    virtual ~PTableEnv() = default;

    int hour24() const override;
};



#endif // P_TABLE_ENV_H


