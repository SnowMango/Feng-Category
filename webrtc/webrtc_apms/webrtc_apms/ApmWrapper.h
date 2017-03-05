#pragma once
#ifndef _APM_WRAPPER_
#define _APM_WRAPPER_
#include <iostream>

enum ApmErr
{
	APMERR_NONE = 0,
	APMERR_BASE = 1,
	APMERR_INITFAIL = 2,
};
class ApmBase
{
public:
	ApmBase(){}
	virtual ~ApmBase() {}

	virtual ApmErr ApmInit()=0;
	virtual ApmErr ApmProcess(unsigned char* data, int size)=0;
	virtual unsigned char* getOutputData()=0;
};

ApmErr	ApmCreate(ApmBase **apms);
void	ApmDestory(ApmBase *apms);
#endif