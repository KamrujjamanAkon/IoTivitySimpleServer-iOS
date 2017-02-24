//
//  ViewController.m
//  IoTivitySimpleServer
//
//  Created by Md. Kamrujjaman Akon on 1/21/17.
//
//

#import "ViewController.h"
#import "IoTvity.h"

@interface ViewController ()

@end

using namespace OC;
namespace PH = std::placeholders;
static id myView;

@implementation ViewController

class LightResource
{
public:
    bool m_state;
    int m_power;
    std::string m_lightUri;
    OCResourceHandle m_resourceHandle;
    OCRepresentation m_lightRep;
    ObservationIds m_interestedObservers;

public:
    LightResource(): m_state(false), m_power(15), m_lightUri("/a/light"), m_resourceHandle(nullptr)
    {
        m_lightRep.setUri(m_lightUri);
        m_lightRep.setValue(STATEKEY, m_state);
        m_lightRep.setValue(POWERKEY, m_power);

    }

    void createResource()
    {
        std::string resourceURI = m_lightUri;
        std::string resourceTypeName = "core.light";
        std::string resourceInterface = DEFAULT_INTERFACE;

        uint8_t resourceProperty = OC_DISCOVERABLE | OC_OBSERVABLE;

        EntityHandler cb = std::bind(&LightResource::entityHandler, this, PH::_1);
        OCStackResult result = OCPlatform::registerResource(m_resourceHandle, resourceURI, resourceTypeName, resourceInterface, cb, resourceProperty);

        if (OC_STACK_OK != result)
            [myView displayLog:@"Resource creation was unsuccessful"];
        else
            [myView displayLog:@"Resource creation successful"];
    }


    OCResourceHandle getHandle()
    {
        return m_resourceHandle;
    }

    void put(OCRepresentation& rep)
    {
        try
        {
            [myView displayLog:@"Representation changed by Client, New representation:"];
            if (rep.getValue(STATEKEY, m_state))
                [myView displayLog:[NSString stringWithFormat:@"State = %d", m_state]];

            if (rep.getValue(POWERKEY, m_power))
                [myView displayLog:[NSString stringWithFormat:@"Power = %d", m_power]];

        }
        catch (NSException *e)
        {
            NSLog(@"Exception in Put = %@", e.reason);
        }

    }



    OCRepresentation get()
    {
        OCRepresentation lightRep;
        lightRep.setValue(STATEKEY, m_state);
        lightRep.setValue(POWERKEY, m_power);
        return lightRep;
    }

private:
    OCEntityHandlerResult entityHandler(std::shared_ptr<OCResourceRequest> request)
    {
        OCEntityHandlerResult ehResult = OC_EH_ERROR;
        if(request)
        {
            std::string requestType = request->getRequestType();
            int requestFlag = request->getRequestHandlerFlag();

            if(requestFlag & RequestHandlerFlag::RequestFlag)
            {
                auto pResponse = std::make_shared<OC::OCResourceResponse>();
                pResponse->setRequestHandle(request->getRequestHandle());
                pResponse->setResourceHandle(request->getResourceHandle());

                if(requestType == "GET")
                {
                    [myView displayLog:@"--------------------------"];
                    [myView displayLog:@"GET request received"];

                    pResponse->setResponseResult(OC_EH_OK);
                    pResponse->setResourceRepresentation(get());
                    if(OC_STACK_OK == OCPlatform::sendResponse(pResponse))
                        ehResult = OC_EH_OK;

                }
                else if(requestType == "PUT")
                {
                    [myView displayLog:@"--------------------------"];
                    [myView displayLog:@"PUT request received"];

                    OCRepresentation rep = request->getResourceRepresentation();
                    put(rep);
                    pResponse->setResponseResult(OC_EH_OK);
                    pResponse->setResourceRepresentation(get());
                    if(OC_STACK_OK == OCPlatform::sendResponse(pResponse))
                    {
                        ehResult = OC_EH_OK;
                    }
                }
            }
        }
        
        return ehResult;
    }
};


- (void)viewDidLoad {
    [super viewDidLoad];

    /*
     * Configuring Platform as a SERVER
     * with connectivity IP and Low Quality of Service
     */

    PlatformConfig cfg(OC::ServiceType::InProc,
                       OC::ModeType::Server,
                       CT_ADAPTER_IP,
                       CT_ADAPTER_IP,
                       OC::QualityOfService::LowQos);

    OCPlatform::Configure(cfg);
    [self displayLog:@"Platform configured as Server"];

    myView = self;

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) displayLog :(NSString *) msg
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *strMsg = [NSString stringWithFormat : @"%@\n",msg];
        NSLog(@"%@", strMsg);

        self.tfDisplayLogs.text = [self.tfDisplayLogs.text stringByAppendingString:strMsg];
        NSRange range = NSMakeRange(self.tfDisplayLogs.text.length - 1, 1);
        [self.tfDisplayLogs scrollRangeToVisible:range];
    });
}

- (IBAction)btnStartServerAction:(id)sender {

    LightResource myLight;
    myLight.createResource();

}

@end

