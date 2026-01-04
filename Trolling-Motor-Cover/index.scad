// --- Configuration ---

// Which part to show? 
// 0 = Assembly (Visual only)
// 1 = Box (Print this)
// 2 = Lid (Print this)
part_to_show = 0; 

// --- Parameters (Dimensions in inches, converted to mm) ---
$fn = 60; 
in_to_mm = 25.4; 
tolerance = 0.4; // Extra gap for hinge fitment

// Dimensions
rec_diameter        = 1.35 * in_to_mm;
rec_internal_depth  = 1.54 * in_to_mm;
mount_hole_diam     = 0.13 * in_to_mm;
mount_hole_spacing  = rec_diameter - mount_hole_diam; 
cable_hole_diam     = 0.5 * in_to_mm; 

// Box Setup
wall_thickness      = 3.0; 
gap_between_recs    = 1.0 * in_to_mm; 
wiring_clearance    = 1.5 * in_to_mm; 

// Hinge Setup
hinge_outer_diam = 8.0; 
hinge_pin_diam   = 3.5; // Sized for M3 screw or loose filament
hinge_knuckle_len = 15.0; 

// Calculated Box Dimensions
box_width  = (rec_diameter * 2) + gap_between_recs + (wall_thickness * 4) + 20;
box_height = rec_diameter + (wall_thickness * 2) + 15;
box_depth  = rec_internal_depth + wiring_clearance;

// --- Rendering Logic ---

if (part_to_show == 0) {
    color("Teal") make_box();
    // Rotate lid to look like it's opening
    translate([0, box_depth/2 + hinge_outer_diam/2, box_height/2]) 
        rotate([-30, 0, 0]) 
        translate([0, -(box_depth/2 + hinge_outer_diam/2), -box_height/2])
        color("Silver") make_lid();
} else if (part_to_show == 1) {
    make_box();
} else if (part_to_show == 2) {
    // Rotate lid flat for printing
    translate([0, 0, wall_thickness]) rotate([180,0,0]) make_lid();
}

// --- Modules ---

module make_box() {
    union() {
        difference() {
            // Main Shell
            cube([box_width, box_depth, box_height], center = true);

            // Hollow Interior (Open Top)
            translate([0, 0, wall_thickness/2 + 0.1])
                cube([
                    box_width - (wall_thickness * 2), 
                    box_depth - (wall_thickness * 2), 
                    box_height 
                ], center = true);

            // Receptacles (Front)
            translate([0, -box_depth/2, 0]) rotate([90, 0, 0]) {
                translate([- (rec_diameter/2 + gap_between_recs/2), 0, -wall_thickness]) receptacle_cutout();
                translate([+ (rec_diameter/2 + gap_between_recs/2), 0, -wall_thickness]) receptacle_cutout();
            }

            // Cables (Back)
            translate([0, box_depth/2, 0]) rotate([90, 0, 0]) {
                translate([- (rec_diameter/2 + gap_between_recs/2), 0, -wall_thickness]) cable_group();
                translate([+ (rec_diameter/2 + gap_between_recs/2), 0, -wall_thickness]) cable_group();
            }
        }
    }
}

module make_lid() {
    lid_thickness = wall_thickness;
    
    union() {
        // The Lid Plate
        translate([0, 0, box_height/2 + lid_thickness/2])
            cube([box_width, box_depth, lid_thickness], center=true);
            
        // The Sealing Lip (Fits inside the box)
        translate([0, 0, box_height/2 - 1]) // Projects 1mm down into box
            cube([
                box_width - (wall_thickness * 2) - tolerance, 
                box_depth - (wall_thickness * 2) - tolerance, 
                2
            ], center=true);
    }
}

module hinge_knuckle() {
    difference() {
        rotate([0, 90, 0]) 
        cylinder(d=hinge_outer_diam, h=hinge_knuckle_len, center=true);
        
        rotate([0, 90, 0]) 
        cylinder(d=hinge_pin_diam, h=hinge_knuckle_len + 1, center=true);
    }
}

module receptacle_cutout() {
    cylinder(d = rec_diameter, h = wall_thickness * 3, center = true);
    offset = mount_hole_spacing / 2;
    for (x = [-1, 1]) {
        for (y = [-1, 1]) {
            translate([x * offset, y * offset, 0])
                cylinder(d = mount_hole_diam, h = wall_thickness * 3, center = true);
        }
    }
}

module cable_group() {
    spacing = cable_hole_diam + 2; 
    translate([0, spacing/2, 0]) cylinder(d = cable_hole_diam, h = wall_thickness * 3, center = true);
    translate([0, -spacing/2, 0]) cylinder(d = cable_hole_diam, h = wall_thickness * 3, center = true);
}