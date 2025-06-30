using WiringPi
using Images
using BMPImages

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
    EPD_7_IN_5_V2_SendData(0xF7)

    EPD_7_IN_5_V2_SendCommand(0x02)
    EPD_7_IN_5_V2_ReadBusyH()

    EPD_7_IN_5_V2_SendCommand(0x07)
    EPD_7_IN_5_V2_SendData(0xA5)

    delay(2000)
    pinMode(EPD_RST_PIN, 0)
    pinMode(EPD_DC_PIN, 0)
    pinMode(EPD_PWR_PIN, 0)
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

    EPD_7_IN_5_V2_SendCommand(0x15)
    EPD_7_IN_5_V2_SendData(0x00)

    EPD_7_IN_5_V2_SendCommand(0x50)
    EPD_7_IN_5_V2_SendData(0x10)
    EPD_7_IN_5_V2_SendData(0x07)

    EPD_7_IN_5_V2_SendCommand(0x60)
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

# Example:

init()
img = fill(0x00, 48_000)

# Fun message

# H
img[22_000:100:26_000] .= 0xff
img[23_498:100:24_498] .= 0xff
img[23_499:100:24_499] .= 0xff
img[21_997:100:25_997] .= 0xff

# I
img[21_994:100:25_994] .= 0xff

# J
img[21_988:100:25_988] .= 0xff
img[25_489:100:25_989] .= 0xff
img[25_490:100:25_990] .= 0xff
img[21_989:100:22_489] .= 0xff
img[21_990:100:22_490] .= 0xff

# U
img[21_986:100:25_986] .= 0xff
img[21_985:100:22_485] .= 0xff
img[21_984:100:22_484] .= 0xff
img[21_983:100:25_983] .= 0xff

# L
img[21_979:100:22_479] .= 0xff
img[21_980:100:22_480] .= 0xff
img[21_981:100:25_981] .= 0xff

# I
img[21_977:100:25_977] .= 0xff

# A
img[21_975:100:25_975] .= 0xff
img[25_474:100:25_974] .= 0xff
img[23_474:100:23_974] .= 0xff
img[21_973:100:25_973] .= 0xff

EPD_7_IN_5_V2_SendCommand(0x10)
EPD_7_IN_5_V2_SendData.(img)

delayMicroseconds(100)
EPD_7_IN_5_V2_SendCommand(0x13)
EPD_7_IN_5_V2_SendData.(img)

delayMicroseconds(100)
EPD_7_IN_5_V2_SendCommand(0x12)
delayMicroseconds(100)

EPD_7_IN_5_V2_ReadBusyH()
EPD_7_IN_5_V2_TurnOnDisplay()

# Read and resize BMP image
bmp = read_bmp("7in5_V2.bmp")
img = imresize(bmp, (100, 480))
img[findall(x -> x != 1.0, img)] .= 0.0
img = replace(img, 0x01 => 0xff)
img = convert.(UInt8, img)

# X's
width = 100
height = 480
img = fill(0x00, width * height)  # start with black image

# Draw a white X
for y in 1:height
    x1 = y % width + 1             # diagonal \
    x2 = (width - (y % width)) + 1 # diagonal /
    
    img[(y - 1) * width + x1] = 0xff
    img[(y - 1) * width + x2] = 0xff
end 
