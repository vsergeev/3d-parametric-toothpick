/********************************************************
 * Parametric Toothpick Frame - vsergeev
 * https://github.com/vsergeev/3d-parametric-toothpick
 * CC-BY-4.0
 * v1.0
 ********************************************************/

/* [General] */

prop_guard_xy_wheelbase = 75;
prop_guard_xy_diameter = 43;
prop_guard_xy_thickness = 1.5;
prop_guard_z_height = 4;
prop_guard_mounting_hole_xy_pitch = 26;

/* [Spacer] */

spacer_z_height = 8;
spacer_xy_diameter = 4;
spacer_mounting_hole_xy_diameter = 2;

/* [Inner Crossbar] */

inner_crossbar_xy_width = 4;
inner_crossbar_z_thickness = prop_guard_z_height / 2;

/* [Outer Crossbar] */

outer_crossbar_xy_width = 4;
outer_crossbar_z_thickness = prop_guard_z_height / 2;
outer_crossbar_xy_offset = 0.4;

/* [Hidden] */

overlap_epsilon = 0.01;

$fn = $preview ? 40 : 100;

/******************************************************************************/
/* 2D Profiles */
/******************************************************************************/

module prop_guard_xy_footprint(profile = false) {
    difference() {
        circle(d=prop_guard_xy_diameter + 2 * prop_guard_xy_thickness);

        if (!profile) {
            circle(d=prop_guard_xy_diameter);
        }
    }
}

module inner_crossbar_xy_footprint() {
    difference() {
        /* Crossbar */
        translate([0,  inner_crossbar_xy_width / 4])
            square([prop_guard_xy_wheelbase, inner_crossbar_xy_width / 2], center=true);

        /* Mounting Hole */
        circle(d=spacer_mounting_hole_xy_diameter);

        /* Subtract overlap with Prop Guards */
        for (i = [0:1]) {
            translate([cos(45 + i * 90) * prop_guard_xy_wheelbase / 2, sin(45 + i * 90) * prop_guard_xy_wheelbase / 2 - (prop_guard_mounting_hole_xy_pitch / 2) / sin(45)])
                prop_guard_xy_footprint(true);
        }
    }
}

module outer_crossbar_xy_footprint() {
    relief_y_length = sin(45) / 2 * prop_guard_xy_wheelbase - sqrt((prop_guard_xy_diameter / 2) ^ 2 - (outer_crossbar_xy_offset * prop_guard_xy_diameter / 2 + outer_crossbar_xy_width) ^ 2);

    difference() {
        square([prop_guard_xy_wheelbase / 2, outer_crossbar_xy_width], center=true);

        /* Relief */
        translate([0, outer_crossbar_xy_width])
            resize([relief_y_length * 2, outer_crossbar_xy_width * 2])
                circle(d=1);

        /* Subtract overlap with Prop Guards */
        for (i = [0:1]) {
            translate([cos(45 + i * 90) * prop_guard_xy_wheelbase / 2, sin(45 + i * 90) * prop_guard_xy_wheelbase / 2 - (sin(45) / 2 * prop_guard_xy_wheelbase + outer_crossbar_xy_width / 2 + prop_guard_xy_diameter / 2 * outer_crossbar_xy_offset)])
                prop_guard_xy_footprint(true);
        }
    }
}

module spacer_xy_footprint() {
    difference() {
        circle(d=spacer_xy_diameter);
        circle(d=spacer_mounting_hole_xy_diameter);
    }
}

/******************************************************************************/
/* 3D Extrustions */
/******************************************************************************/

module inner_crossbar() {
    /* Crossbar */
    translate([0, 0, prop_guard_z_height - inner_crossbar_z_thickness])
        linear_extrude(inner_crossbar_z_thickness)
            inner_crossbar_xy_footprint();
}

module outer_crossbar() {
    /* Crossbar */
    translate([0, 0, prop_guard_z_height - outer_crossbar_z_thickness])
        linear_extrude(outer_crossbar_z_thickness)
            outer_crossbar_xy_footprint();
}

module spacer() {
    /* Spacer */
    translate([0, 0, prop_guard_z_height - spacer_z_height + overlap_epsilon])
        linear_extrude(spacer_z_height)
            spacer_xy_footprint();
}

module prop_guard() {
    union() {
        /* Prop Guards */
        for (i = [0:3]) {
            translate([cos(45 + i * 90) * prop_guard_xy_wheelbase / 2, sin(45 + i * 90) * prop_guard_xy_wheelbase / 2])
                linear_extrude(prop_guard_z_height)
                    prop_guard_xy_footprint();
        }

        /* Inner Crossbars */
        for (i = [0:3]) {
            rotate(90 * i)
                translate([0, (prop_guard_mounting_hole_xy_pitch / 2) / sin(45)])
                    inner_crossbar();
        }

        /* Spacers */
        for (i = [0:3]) {
            rotate(90 * i)
                translate([0, (prop_guard_mounting_hole_xy_pitch / 2) / sin(45)])
                    spacer();
        }

        /* Outer Crossbars */
        for (i = [0:3]) {
            rotate(90 * i)
                translate([0, sin(45) / 2 * prop_guard_xy_wheelbase + outer_crossbar_xy_width / 2 + prop_guard_xy_diameter / 2 * outer_crossbar_xy_offset])
                outer_crossbar();
        }
    }
}
