$fn = 100;

module spacer(diameter, bore_diameter, thickness) {
    linear_extrude(thickness) {
        difference() {
            circle(d=diameter);
            circle(d=bore_diameter);
        }
    }
}

spacer(4, 2, 2);
