using WiringPi

# TODO: Compare every single function with epd7in5_V2.py The good news is that WiringPi should have every function needed here. 
# NOTE: send_data2 is a loop over the send_data command to my knowledge
# NOTE: The colors will need to be updated but that can come later
    
const EPD_RST_PIN = 17
const EPD_DC_PIN = 25
const EPD_CS_PIN = 8
const EPD_PWR_PIN = 18
const EPD_BUSY_PIN = 24
const EPD_MOSI_PIN = 10
const EPD_SCLK_PIN = 11

const EPD_7_IN_5_V2_WIDTH = 800
const EPD_7_IN_5_V2_HEIGHT = 480

const EPD_7_IN_5_V2_BLACK = 0x0   
const EPD_7_IN_5_V2_WHITE = 0x1   
const EPD_7_IN_5_V2_GREEN = 0x2  
const EPD_7_IN_5_V2_BLUE = 0x3   
const EPD_7_IN_5_V2_RED = 0x4   
const EPD_7_IN_5_V2_YELLOW = 0x5   
const EPD_7_IN_5_V2_ORANGE = 0x6   
const EPD_7_IN_5_V2_CLEAN = 0x7  
const EPD_7_IN_5_V2_GRAY1  = 0xff #white
const EPD_7_IN_5_V2_GRAY2  = 0xC0
const EPD_7_IN_5_V2_GRAY3  = 0x80 #gray
const EPD_7_IN_5_V2_GRAY4  = 0x00 #black

function EPD_7_IN_5_V2_Display(Image::Vector{UInt8})

    Width::Int64 = (EPD_7_IN_5_V2_WIDTH % 2 == 0) ? (EPD_7_IN_5_V2_WIDTH / 2 ) : (EPD_7_IN_5_V2_WIDTH / 2 + 1)
    Height::Int64 = EPD_7_IN_5_V2_HEIGHT

    EPD_7_IN_5_V2_SendCommand(0x10)
    for  j::Int64=0:Height-1
        for i::Int64=1:Width
            EPD_7_IN_5_V2_SendData(Image[i + j * Width])
        end
    end
    EPD_7_IN_5_V2_TurnOnDisplay()
end


function EPD_7_IN_5_V2_Sleep()
    EPD_7_IN_5_V2_SendCommand(0x50)
    EPD_7_IN_5_V2_SendData(0XF7)

    EPD_7_IN_5_V2_SendCommand(0x02)
    EPD_7_IN_5_V2_ReadBusyH()

    EPD_7_IN_5_V2_SendCommand(0x07)
    EPD_7_IN_5_V2_SendData(0XA5)

    delay(2000)
    # TODO: I do not know how to implement the module_exit method just yet
    # epdconfig.module_exit()
end



# TODO: Redo this function
function EPD_7_IN_5_V2_Clear( color::UInt8)
   
    EPD_7_IN_5_V2_SendCommand(0x10)

    EPD_7_IN_5_V2_SendCommand(0x13)

    Width = (EPD_7_IN_5_V2_WIDTH % 2 == 0) ? (EPD_7_IN_5_V2_WIDTH / 2 ) : (EPD_7_IN_5_V2_WIDTH / 2 + 1)
    Height = EPD_7_IN_5_V2_HEIGHT

    EPD_7_IN_5_V2_SendCommand(0x10)
    for j=1:Height 
        for  i=1:Width
            EPD_7_IN_5_V2_SendData((color<<4)|color)
        end
    end

    EPD_7_IN_5_V2_TurnOnDisplay()
end      

function DEV_SPI_WriteByte(Value)
    v = Ref{Cuchar}(Value)
    wiringPiSPIDataRW(0,v,1)
end

function EPD_7_IN_5_V2_SendCommand(Reg::UInt8)
    digitalWrite(EPD_DC_PIN, 0)
    digitalWrite(EPD_CS_PIN, 0)
    DEV_SPI_WriteByte(Reg)
    digitalWrite(EPD_CS_PIN, 1)
end

function EPD_7_IN_5_V2_SendData(Data::UInt8)
    digitalWrite(EPD_DC_PIN, 1)
    digitalWrite(EPD_CS_PIN, 0)
    DEV_SPI_WriteByte(Data)
    digitalWrite(EPD_CS_PIN, 1)
end

function EPD_7_IN_5_V2_TurnOnDisplay()
    EPD_7_IN_5_V2_SendCommand(0x04) 
    EPD_7_IN_5_V2_ReadBusyH()
    delay(30)

    EPD_7_IN_5_V2_SendCommand(0x12) 
    EPD_7_IN_5_V2_SendData(0x0)
    EPD_7_IN_5_V2_ReadBusyH()
    delay(30)

    EPD_7_IN_5_V2_SendCommand(0x02) 
    EPD_7_IN_5_V2_SendData(0x0)
    EPD_7_IN_5_V2_ReadBusyH()
    delay(30)
end


function EPD_7_IN_5_V2_ReadBusyH()
    println("e-Paper busy")

    EPD_7_IN_5_V2_SendCommand(0x71) 
    busy = digitalRead(EPD_BUSY_PIN)
    while(busy == 0) 
        EPD_7_IN_5_V2_SendCommand(0x71) 
        busy = digitalRead(EPD_BUSY_PIN)
        delay(1)
    end
    delay(20)
    println("e-Paper Busy Release")
end

function EPD_7_IN_5_V2_Reset()
    digitalWrite(EPD_RST_PIN, 1)
    delay(20)
    digitalWrite(EPD_RST_PIN, 0)
    delay(2)
    digitalWrite(EPD_RST_PIN, 1)
    delay(20)
end

function EPD_7_IN_5_V2_Init()

    EPD_7_IN_5_V2_Reset()
    EPD_7_IN_5_V2_ReadBusyH()
    delay(30)

    EPD_7_IN_5_V2_SendCommand(0x06)    
    EPD_7_IN_5_V2_SendData(0x17)
    EPD_7_IN_5_V2_SendData(0x17)
    EPD_7_IN_5_V2_SendData(0x28)
    EPD_7_IN_5_V2_SendData(0x17)

    EPD_7_IN_5_V2_SendCommand(0x01)
    EPD_7_IN_5_V2_SendData(0x07)
    EPD_7_IN_5_V2_SendData(0x07)
    EPD_7_IN_5_V2_SendData(0x28)
    EPD_7_IN_5_V2_SendData(0x17)

    EPD_7_IN_5_V2_SendCommand(0x04)
    delay(100)
    EPD_7_IN_5_V2_ReadBusyH()

    EPD_7_IN_5_V2_SendCommand(0x00)
    EPD_7_IN_5_V2_SendData(0x1F)

    EPD_7_IN_5_V2_SendCommand(0x61)
    EPD_7_IN_5_V2_SendData(0x03)
    EPD_7_IN_5_V2_SendData(0x20)
    EPD_7_IN_5_V2_SendData(0x01)
    EPD_7_IN_5_V2_SendData(0xE0) 

    EPD_7_IN_5_V2_SendCommand(0X15)
    EPD_7_IN_5_V2_SendData(0x00)

    EPD_7_IN_5_V2_SendCommand(0X50)
    EPD_7_IN_5_V2_SendData(0x10)
    EPD_7_IN_5_V2_SendData(0x07)

    EPD_7_IN_5_V2_SendCommand(0X60)
    EPD_7_IN_5_V2_SendData(0x22)
    
end

function init()
    wiringPiSetupGpio()
    pinMode(EPD_BUSY_PIN, 0)
    pullUpDnControl(EPD_BUSY_PIN, PUD_UP)
    pinMode(EPD_RST_PIN, 1)
    pinMode(EPD_DC_PIN, 1)
    pinMode(EPD_CS_PIN, 1)
    pinMode(EPD_PWR_PIN, 1)
    digitalWrite(EPD_CS_PIN, 1)
    digitalWrite(EPD_PWR_PIN, 1)
    wiringPiSPISetup(0,10000000)
    EPD_7_IN_5_V2_Init()
end

function shutDown()
    EPD_7_IN_5_V2_Sleep()
    delay(2000)
    digitalWrite(EPD_CS_PIN, 0)
    digitalWrite(EPD_PWR_PIN, 0)
    digitalWrite(EPD_DC_PIN, 0)    
    digitalWrite(EPD_RST_PIN, 0)
end

