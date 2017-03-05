// ApmWrapper.cpp : ∂®“Âøÿ÷∆Ã®”¶”√≥Ã–Úµƒ»Îø⁄µ„°£
//

#include "ApmWrapper.h"
#include <iostream>

#include "audio_processing.h"
#include "module_common_types.h"
using namespace std;
using namespace webrtc;

class ApmWrapper : public ApmBase 
{
public:
	ApmWrapper();
	~ApmWrapper();
	ApmErr ApmInit();
	ApmErr ApmProcess(unsigned char* data, int size);
	unsigned char* getOutputData();
protected:
	AudioProcessing		*Apm;
	AudioFrame			pcmFrame;
	//data optimized by audio processing
	unsigned char*		opt_data;
    unsigned int        buffsize;
};


ApmWrapper::ApmWrapper():
	opt_data(NULL),
	Apm(NULL),
    buffsize(0)
{

}


ApmWrapper::~ApmWrapper()
{
//	AudioProcessing::Destroy(Apm);
	if (Apm != NULL)
	{
		delete Apm;
		Apm = NULL;
	}
}

ApmErr ApmWrapper::ApmInit()
{	
	Apm = AudioProcessing::Create();
//	Apm->set_sample_rate_hz(8000); // 
//	
//	Apm->set_num_channels(1, 1);
//	Apm->set_num_reverse_channels(1);

	//Apm->high_pass_filter()->Enable(true);
	/*
	Apm->voice_detection()->Enable(true);
	Apm->voice_detection()->set_likelihood(VoiceDetection::Likelihood::kVeryLowLikelihood);
	Apm->echo_cancellation()->set_suppression_level(EchoCancellation::SuppressionLevel::kHighSuppression);
	Apm->echo_cancellation()->enable_drift_compensation(false);
	Apm->echo_cancellation()->Enable(true);		
	Apm->gain_control()->set_analog_level_limits(0, 255);
	Apm->gain_control()->set_mode(GainControl::Mode::kAdaptiveAnalog);
	Apm->gain_control()->Enable(true);*/

	Apm->noise_suppression()->set_level(NoiseSuppression::Level::kHigh);
	Apm->noise_suppression()->Enable(true);	
	int ret = Apm->Initialize();

	if (ret != 0)
		return APMERR_INITFAIL;

	return APMERR_NONE;
}

ApmErr ApmWrapper::ApmProcess(unsigned char* data, int size)
{
    if (opt_data)
    {
        if (buffsize < size)
        {
            delete opt_data;
            opt_data = new unsigned char[size];
            memset(opt_data, 0 , size);
            buffsize = size;
        }else{
            memset(opt_data, 0, buffsize);
        }
    }
    else{
        opt_data = new unsigned char[size];
        buffsize = size;
    }
    unsigned char *ptr = opt_data;
    while (size){
        pcmFrame.UpdateFrame(0, 0, (const int16_t*)data, 80, 8000, AudioFrame::kNormalSpeech, AudioFrame::kVadActive, 1);
        int res = Apm->ProcessReverseStream(&pcmFrame);
        Apm->gain_control()->set_stream_analog_level(1);
        Apm->set_stream_delay_ms(100);
        int err = Apm->ProcessStream(&pcmFrame);
        if (err != 0)
            return APMERR_BASE;
        if (size < 160)
        {
            memcpy(ptr, pcmFrame.data_,size);
        }else{
            memcpy(ptr, pcmFrame.data_,160);// 16bit->2byte*80
        }
        ptr += 160;
        data += 160;
        size -= 160;
        if(size < 0)
            size = 0;
    }
    return APMERR_NONE;
    
}
unsigned char* ApmWrapper::getOutputData()
{
	return opt_data;
}

ApmErr ApmCreate(ApmBase **apms)
{
	ApmWrapper *apm = new ApmWrapper();
	*apms = apm;
	if (apms == NULL)
	{
		return APMERR_NONE;
	}
	return APMERR_NONE;
}
void	ApmDestory(ApmBase *apms)
{
	if (apms)
	{
		delete apms;
		apms = NULL;
	}
}
//int _tmain(int argc, _TCHAR* argv[])
//{
//	FILE* infile = fopen("D:\\micsrc.pcm", "rb");
//	FILE* outfile = fopen("des.pcm", "wb");
//	unsigned char *input = new unsigned char[960 * sizeof(int16_t)+1];
//	ApmBase *ap;
//	ApmCreate(&ap);
//	ap->ApmInit();
//	while (fread(input,sizeof(int16_t),960,infile))
//	{
//		ap->ApmProcess(input, 1920);
//		fwrite(ap->getOutputData(), sizeof(int16_t), 960, outfile);
//		fflush(outfile);
//	}
//	fclose(outfile);
//	fclose(infile);
//	system("pause");
//	return 0;
//}

