/********************************************************
 * Parametric Toothpick Frame - vsergeev
 * https://github.com/vsergeev/3d-parametric-toothpick
 * CC-BY-4.0
 * v1.0
 ********************************************************/

/* [General] */

toothpick_xy_wheelbase = 75;
toothpick_z_thickness = 1.8;
toothpick_arm_xy_width = 4.5;

/* [Flight Controller Mount] */

fc_mounting_hole_xy_pitch = 26;
fc_mounting_hole_xy_diameter = 2;
fc_mounting_hole_counterbore_xy_diameter = 3.25;
fc_mounting_hole_counterbore_z_depth = toothpick_z_thickness / 2;
fc_mounting_ring_xy_diameter = 4.75;
fc_mounting_crossbar_xy_width = 2.5;
fc_mounting_crossbar_xy_radius = 1;

/* [Support Crossbar] */

support_crossbar_enabled = true;
support_crossbar_xy_width = 2.5;

/* [Motor Base] */

motor_base_xy_diameter = 10;
motor_base_xy_mounting_holes = [[4.2, 0, 0], [1.6, 6.6 / 2, 0], [1.6, 6.6 / 2, 120], [1.6, 6.6 / 2, 240]];

/* [Battery Strap Slot] */

battery_strap_slot_dimensions = [1.75, 13];
battery_strap_slot_x_pitch = 10;
battery_strap_crossbar_xy_width = 2;
battery_strap_crossbar_xy_radius = 2;

/* [Hidden] */

overlap_epsilon = 0.01;

$fn = $preview ? 40 : 100;

/******************************************************************************/
/* 2D Profiles */
/******************************************************************************/

module motor_base_xy_footprint(profile = false) {
    difference() {
        circle(d=motor_base_xy_diameter);

        if (!profile) {
            /* Mounting Holes */
            for (mounting_hole = motor_base_xy_mounting_holes) {
                rotate(mounting_hole[2])
                    translate([0, mounting_hole[1]])
                        circle(d=mounting_hole[0]);
            }
        }
    }
}

module fc_mount_xy_footprint() {
    difference() {
        union() {
            /* Crossbar */
            for (i = [0:3]) {
                rotate(i * 90)
                    offset(r=fc_mounting_crossbar_xy_radius)
                        offset(delta=-fc_mounting_crossbar_xy_radius)
                            polygon([
                                [(fc_mounting_hole_xy_pitch / sin(45)) / 2, -fc_mounting_ring_xy_diameter],
                                [(fc_mounting_hole_xy_pitch / sin(45)) / 2, fc_mounting_ring_xy_diameter],
                                [fc_mounting_ring_xy_diameter, (fc_mounting_hole_xy_pitch / sin(45)) / 2],
                                [-fc_mounting_ring_xy_diameter, (fc_mounting_hole_xy_pitch / sin(45)) / 2],
                                [-fc_mounting_ring_xy_diameter, (fc_mounting_hole_xy_pitch / sin(45)) / 2 + fc_mounting_crossbar_xy_width],
                                [fc_mounting_ring_xy_diameter + fc_mounting_crossbar_xy_width / 2, (fc_mounting_hole_xy_pitch / sin(45)) / 2 + fc_mounting_crossbar_xy_width],
                                [(fc_mounting_hole_xy_pitch / sin(45)) / 2 + fc_mounting_crossbar_xy_width, fc_mounting_ring_xy_diameter + fc_mounting_crossbar_xy_width / 2],
                                [(fc_mounting_hole_xy_pitch / sin(45)) / 2 + fc_mounting_crossbar_xy_width, -fc_mounting_ring_xy_diameter],
                            ]);
            }

            /* Mounting Rings */
            for (i = [0:3]) {
                rotate(i * 90)
                    translate([(fc_mounting_hole_xy_pitch / sin(45)) / 2, 0])
                        circle(d=fc_mounting_ring_xy_diameter);
            }
        }

        /* Mounting Holes */
        for (i = [0:3]) {
            rotate(i * 90)
                translate([(fc_mounting_hole_xy_pitch / sin(45)) / 2, 0])
                    circle(d=fc_mounting_hole_xy_diameter);
        }
    }
}

module fc_mount_counterbores_xy_footprint() {
    union() {
        /* Mounting Hole Counterbores */
        for (i = [0:3]) {
            rotate(i * 90)
                translate([(fc_mounting_hole_xy_pitch / sin(45)) / 2, 0])
                    circle(d=fc_mounting_hole_counterbore_xy_diameter);
        }
    }
}

module battery_strap_slot_xy_footprint(profile = false) {
    difference() {
        /* Base */
        offset(r=battery_strap_crossbar_xy_radius)
            offset(delta=-battery_strap_crossbar_xy_radius)
                square([battery_strap_slot_x_pitch + battery_strap_slot_dimensions.x + battery_strap_crossbar_xy_width * 2,
                        battery_strap_slot_dimensions.y + battery_strap_crossbar_xy_width * 2], center=true);

        if (!profile) {
            /* Left Slot */
            translate([-battery_strap_slot_x_pitch / 2, 0])
                square(battery_strap_slot_dimensions, center=true);

            /* Right Slot */
            translate([battery_strap_slot_x_pitch / 2, 0])
                square(battery_strap_slot_dimensions, center=true);
        }
    }
}

module support_crossbar_xy_footprint() {
    difference() {
        /* Arm */
        translate([-cos(45) * toothpick_xy_wheelbase / 2, -support_crossbar_xy_width / 2])
            square([cos(45) * toothpick_xy_wheelbase, support_crossbar_xy_width]);

        /* Subtract Motor Base Profile */
        translate([cos(45) * toothpick_xy_wheelbase / 2, 0])
            circle(d=motor_base_xy_diameter - overlap_epsilon);
        translate([-cos(45) * toothpick_xy_wheelbase / 2, 0])
            circle(d=motor_base_xy_diameter - overlap_epsilon);
    }
}

module toothpick_arm_xy_footprint() {
    difference() {
        /* Arm */
        translate([0, -toothpick_arm_xy_width / 2])
            square([toothpick_xy_wheelbase / 2, toothpick_arm_xy_width]);

        /* Subtract Motor Base Profile */
        translate([toothpick_xy_wheelbase / 2, 0])
            motor_base_xy_footprint(true);
    }
}

module toothpick_xy_footprint() {
    union() {
        difference() {
            /* Arms */
            for (i = [0:3])
                rotate(i * 90 + 45)
                    toothpick_arm_xy_footprint();

            /* Subtract Battery Strap Slot Profile */
            battery_strap_slot_xy_footprint(true);
        }

        /* Support Crossbars */
        if (support_crossbar_enabled) {
            for (i = [0:3])
                rotate(i * 90)
                    translate([0, sin(45) * toothpick_xy_wheelbase / 2])
                        support_crossbar_xy_footprint();
        }

        /* Motor Mounts */
        for (i = [0:3]) {
            translate([cos(45 + i * 90) * toothpick_xy_wheelbase / 2, sin(45 + i * 90) * toothpick_xy_wheelbase / 2])
                rotate(i < 2 ? 180 : 0)
                    motor_base_xy_footprint();
        }

        /* Battery Strap Slot */
        battery_strap_slot_xy_footprint();

        /* Flight Controller Mount */
        fc_mount_xy_footprint();
    }
}

/******************************************************************************/
/* 3D Extrustions */
/******************************************************************************/

module toothpick() {
    difference() {
        linear_extrude(toothpick_z_thickness, convexity=3)
            toothpick_xy_footprint();

        translate([0, 0, -overlap_epsilon])
            linear_extrude(fc_mounting_hole_counterbore_z_depth)
                fc_mount_counterbores_xy_footprint();
    }
}
