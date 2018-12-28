#  module Maestro

#  export startservo, stopservo
#  export setaccel, setspeed, settarget

using SerialPorts

@enum GripperMode grasped released
mutable struct Gripper
    mode::GripperMode
    servos::SerialPort
end

function startgripper(port::String="/dev/ttyACM0", baud::Int=250000)
    servos = SerialPort(port, baud)
    gripper = Gripper(grasped, servos)
    grasp!(gripper)
    return gripper
end

function stopgripper(gripper::Gripper)
    close(gripper.servos)
end

tocmd(args...) = String([UInt8(x) for x in args])

function settarget(serial::SerialPort, channel::Int, target::Int)
    lsb = target & 0x7f
    msb = (target >> 7) & 0x7f
    cmd = tocmd(0xaa, 0x0c, 0x04, channel, lsb, msb)
    write(serial, cmd)
end

function grasp!(gripper::Gripper)
    settarget(gripper.servos, 0, 7700)
    settarget(gripper.servos, 1, 8100)
    gripper.mode = grasped
end

function release!(gripper::Gripper)
    settarget(gripper.servos, 0, 1000)
    settarget(gripper.servos, 1, 1000)
    gripper.mode = released
end

#  end # module
