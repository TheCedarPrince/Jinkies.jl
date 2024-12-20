module Jinkies

using PiGPIO

include("RPI_CONSTANTS.jl")

function initialize(p::Pi)
    set_mode(p, RST_PIN, PiGPIO.OUTPUT)
    set_mode(p, DC_PIN, PiGPIO.OUTPUT)
    set_mode(p, PWR_PIN, PiGPIO.OUTPUT)
    set_mode(p, MOSI_PIN, PiGPIO.OUTPUT)
    set_mode(p, SCLK_PIN, PiGPIO.OUTPUT)

    set_pull_up_down(p, BUSY_PIN, PiGPIO.PUD_OFF)
end

function digital_write(p, pin, value)
    if pin == RST_PIN
        if value
            PiGPIO.write(p, RST_PIN, PiGPIO.ON)
        else
            PiGPIO.write(p, RST_PIN, PiGPIO.OFF)
        end
    elseif pin == DC_PIN
        if value
            PiGPIO.write(p, DC_PIN, PiGPIO.ON)
        else
            PiGPIO.write(p, DC_PIN, PiGPIO.OFF)
        end
    elseif pin == PWR_PIN
        if value
            PiGPIO.write(p, PWR_PIN, PiGPIO.ON)
        else
            PiGPIO.write(p, PWR_PIN, PiGPIO.OFF)
        end
    end
end

function digital_read(p, pin)
    if pin == BUSY_PIN
        return PiGPIO.read(p, BUSY_PIN)
    elseif pin == RST_PIN
        return PiGPIO.read(p, RST_PIN)
    elseif pin == DC_PIN
        return PiGPIO.read(p, DC_PIN)
    elseif pin == PWR_PIN
        return PiGPIO.read(p, PWR_PIN)
    end
end

function delay_ms(delaytime)
    sleep(delaytime / 1000)
end

function module_init(p, cleanup = false)

end

function reset_epd(p::Pi)

    digital_write(p, reset_pin, 1)
    delay_ms(20)
    digital_write(p, reset_pin, 0)
    delay_ms(2)
    digital_write(p, reset_pin, 1)
    delay_ms(20)

end

end
