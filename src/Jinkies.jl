module Jinkies

    using WiringPi

    include("constants.jl")

    function binarize_image(img)
        binary_img = img .< 0.5

        h, w = size(binary_img)
        bytes_per_row = ceil(Int, w / 8)
        out = fill(UInt8(0xFF), h * bytes_per_row)

        for j in 1:h
            for i in 1:w
                byte_index = div(i - 1, 8) + 1
                bit_index = 7 - ((i - 1) % 8)
                pixel = binary_img[j, i]
                if pixel
                    out[(j - 1) * bytes_per_row + byte_index] &= ~(UInt8(1) << bit_index)
                end
            end
        end

        return out, .~out
    end

    function display_image(img)
        send_command(0x10)
        send_data.(img)

        delayMicroseconds(100)
        send_command(0x13)
        send_data.(.~img)

        delayMicroseconds(100)
        send_command(0x12)

        read_busy()
        turn_on_display()
    end

    function sleep_display()
        send_command(0x50)
        send_data(0xF7)

        send_command(0x02)
        read_busy()

        send_command(0x07)
        send_data(0xA5)

        delay(2000)
        pinMode(EPD_RST_PIN, 0)
        pinMode(EPD_DC_PIN, 0)
        pinMode(EPD_PWR_PIN, 0)
    end

    function clear_display(color::UInt8)
        send_command(0x10)
        send_command(0x13)

        Width = (EPD_7_IN_5_WIDTH % 2 == 0) ? (EPD_7_IN_5_WIDTH / 2 ) : (EPD_7_IN_5_WIDTH / 2 + 1)
        Height = EPD_7_IN_5_HEIGHT

        send_command(0x10)
        for j=1:Height 
            for  i=1:Width
                send_data((color<<4)|color)
            end
        end

        turn_on_display()
    end      

    function dev_spi_writebyte(Value)
        v = Ref{Cuchar}(Value)
        wiringPiSPIDataRW(0,v,1)
    end

    function send_command(Reg::UInt8)
        digitalWrite(EPD_DC_PIN, 0)
        digitalWrite(EPD_CS_PIN, 0)
        dev_spi_writebyte(Reg)
        digitalWrite(EPD_CS_PIN, 1)
    end

    function send_data(Data::UInt8)
        digitalWrite(EPD_DC_PIN, 1)
        digitalWrite(EPD_CS_PIN, 0)
        dev_spi_writebyte(Data)
        digitalWrite(EPD_CS_PIN, 1)
    end

    function turn_on_display()
        send_command(0x04) 
        read_busy()
        delay(30)

        send_command(0x12) 
        send_data(0x0)
        read_busy()
        delay(30)

        send_command(0x02) 
        send_data(0x0)
        read_busy()
        delay(30)
    end


    function read_busy()
        println("e-Paper busy")

        send_command(0x71) 
        busy = digitalRead(EPD_BUSY_PIN)
        while(busy == 0) 
            send_command(0x71) 
            busy = digitalRead(EPD_BUSY_PIN)
            delay(1)
        end
        delay(20)
        println("e-Paper Busy Release")
    end

    function reset_display()
        digitalWrite(EPD_RST_PIN, 1)
        delay(20)
        digitalWrite(EPD_RST_PIN, 0)
        delay(2)
        digitalWrite(EPD_RST_PIN, 1)
        delay(20)
    end

    function init()
        reset_display()
        read_busy()
        delay(30)

        send_command(0x06)    
        send_data(0x17)
        send_data(0x17)
        send_data(0x28)
        send_data(0x17)

        send_command(0x01)
        send_data(0x07)
        send_data(0x07)
        send_data(0x28)
        send_data(0x17)

        send_command(0x04)
        delay(100)
        read_busy()

        send_command(0x00)
        send_data(0x1F)

        send_command(0x61)
        send_data(0x03)
        send_data(0x20)
        send_data(0x01)
        send_data(0xE0) 

        send_command(0x15)
        send_data(0x00)

        send_command(0x50)
        send_data(0x10)
        send_data(0x07)

        send_command(0x60)
        send_data(0x22)
    end

    function initialize_display()
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
        init()
    end

    function shutdown_display()
        sleep_display()
        delay(2000)
        digitalWrite(EPD_CS_PIN, 0)
        digitalWrite(EPD_PWR_PIN, 0)
        digitalWrite(EPD_DC_PIN, 0)    
        digitalWrite(EPD_RST_PIN, 0)
    end

end
