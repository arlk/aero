#!/usr/bin/env julia

include("maestro.jl")

using RobotOS
@rosimport sensor_msgs.msg: Joy
rostypegen()
using .sensor_msgs.msg

@enum PropsMode armed disarmed
@enum FlightMode onground inair

mutable struct AeroSM
    gripper::Gripper
    props::PropsMode
    flight::FlightMode
end

function joycb!(msg::Joy, aero::AeroSM)
    if msg.buttons[28] == 1
        if aero.gripper.mode == grasped
            loginfo("Gripper: Releasing")
            release!(aero.gripper)
        elseif aero.gripper.mode == released
            loginfo("Gripper: Grasping")
            grasp!(aero.gripper)
        end
    end
end

function main()
    init_node("aerosm")
    gripper = startgripper()
    aero = AeroSM(gripper, disarmed, onground)
    sub = Subscriber{Joy}("joy", joycb!, (aero, ), queue_size=10)
    spin()
end

if ! isinteractive()
    main()
end
