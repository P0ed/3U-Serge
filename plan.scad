use <Futura Medium.otf>

$fn = 128;

tolerance = 0.1;
m3 = 3.0 + tolerance;
3U = 128.5;

bx = 25.4;
by = 19.05;

function HP(x) = 5.08 * x;

module M3() { circle(d = m3); }
module MiniJack() { circle(d = 6.0 + tolerance); }
module Toggle() { circle(d = 6.35 + tolerance); }
module Button() { circle(d = 6.35 + tolerance); }
module Pot() { circle(d = 7.0 + tolerance); }
module LED3() { circle(d = 4.34 + tolerance); }
module LED5() { circle(d = 6.35 + tolerance); }

module Banana() {
	intersection() { 
		circle(d = 8.0 + tolerance);
		square(
			size = [6.35 + tolerance, 8.0 + tolerance], 
			center = true
		);
	}
}

// Switchcraft N112BPCX
module Jack() {
	intersection() {
		circle(d = 9.525 + tolerance);
		square(
			size = [8.382 + tolerance, 9.525 + tolerance], 
			center = true
		);
	}
}

module XLR() {
	d = 24.0;
	id = 23.6;
	hd = 19.0;
	
	circle(d = id);
	translate([-hd / 2, d / 2]) M3();
	translate([hd / 2, -d / 2]) M3();
}

module roundRect(w, h, r) {
	hull() {
		translate([r, r]) circle(d = r * 2);
		translate([r, h - r]) circle(d = r * 2);
		translate([w - r, r]) circle(d = r * 2);
		translate([w - r, h - r]) circle(d = r * 2);
	}
}

module 3UPanel(hp) {
    w = HP(hp);
    h = 3U;
    hx = 7.5;
    hy = 3.0;

	difference() {
		roundRect(w, h, 1);
		translate([w / 2, h / 2])
		4holes(w - hx * 2, h - hy * 2, d = m3);

        children();
    }
}

module 4holes(w, h, d = m3, hx = 0) {
	translate([w / 2, h / 2]) hull() {
		circle(d = d);
		translate([-hx, 0]) circle(d = d);
	}
	translate([-w / 2, h / 2]) hull() {
		circle(d = d);
		translate([hx, 0]) circle(d = d);
	}
	translate([w / 2, -h / 2]) hull() {
		circle(d = d);
		translate([-hx, 0]) circle(d = d);
	}
	translate([-w / 2, -h / 2]) hull() {
		circle(d = d);
		translate([hx, 0]) circle(d = d);
	}
}

module line(start, end, thickness = 1) {
    hull() {
        translate(start) circle(thickness);
        translate(end) circle(thickness);
    }
}

module txt(text, size) {
	text(
		text = text,
		size = size,
		halign = "center",
		valign = "center",
		font = "Futura:style=Medium"
	);
}

module Serge() {
	dx = (HP(42) - bx * 7) / 2;
	dy = (3U - by * 4) / 2;

	function gx(x) = bx * x + dx;
	function gy(y) = by * y + dy;
	function grid(x, y) = [gx(x), gy(y)];

	module label(x, y, text) {
		translate(grid(x, y))
		translate([0, -9])
		txt(text, len(text) == 1 ? 2.6 : 2.0);
	}
	
	module led(x, y) { translate(grid(x, y)) LED3(); }
	module led5(x, y) { translate(grid(x, y)) LED5(); }
		
	module border(delta) {
		difference() {
			children();
			offset(delta = -delta) children();
		}
	}

	module frame(width, height) {
		ex = 11.8;
		ey = 10.7;
		translate([-ex, -ey])
		border(0.5)
		roundRect(bx * (width - 1) + ex * 2, by * (height - 1) + ey * 2, 4);
	}

	module unit(width, name) {
		frame(width, 5);

		translate([bx * (width - 1) / 2, by * (5 - 1) + 14.8]) 
		txt(name, 2.8);
	}

	module connect(x, y, tx, ty, thickness = 0.14) {
		line(grid(x, y), grid(tx, ty), thickness);
	}

	module bipolar(x, y) {

		module side() {
			difference() {
				translate([0, -1.5]) circle(9);
				circle(7.25);
				translate([-1.25, -10]) square([20, 20]);
				line([-1.3, -8.8], [1.3, -8.8], 3.4);
			}
		}

		translate(grid(x, y)) {
			border(0.25) side();
			mirror([1, 0]) side();
		}
	}

	module do(cx, cy, sx = 1, sy = 1) {
		for (x = [0 : cx - 1]) {
			for (y = [0 : cy - 1]) {
				translate([bx * x * sx, by * y * sy]) children();
			}
		}
	}

	module paintjob() {
		// Gate seq
		translate([bx * 0, 0]) {
			label(2, 1, "RESET");
			label(2, 2, "HOLD");
			label(2, 3, "CLOCK");
		}

		// Comparator
		translate([bx * 3, 0]) {
			//label(0, 2, "IN");
			//do(1, 2, sy = 2) label(0, 1, "−5   +5");
			do(1, 2, sy = 2) bipolar(0, 1);
			do(1, 2, sy = 4) label(0, 0, "+");
			//do(1, 3, sy = 2) label(1, 0, "OUT");
			do(1, 2, sy = 2) label(1, 1, "−");
			label(0.5, 2, "SCHMITT TRIGGER");
		}

		// CV Pro
		translate([bx * 5, 0]) {
			do(1, 1) bipolar(0, 2);
			//label(0, 2, "−5   +5");
			do(1, 2, sy = 3) {	
				do(1, 2) bipolar(2, 0);
				//label(0.5, 0.5, "OUT");
			}
		}

		translate(grid(0, 0)) unit(3, "GATE SEQUENCER");
		translate(grid(3, 0)) unit(2, "COMPARATOR");
		translate(grid(5, 0)) unit(3, "DUAL PROCESSOR");
		translate(grid(3, 2)) frame(2, 3);
		translate(grid(3, 3)) frame(2, 2);

		//do(8, 5) translate(grid(0, 0)) circle(d = 11.13);
	}

	module panel() {
		3UPanel(42) {
			translate([bx * 0, 0]) {
				// Gate sequencer
				translate(grid(0, 0)) do(2, 5) Banana();
				do(2, 5) led(0.5, 0);
				translate(grid(2, 0)) Toggle();
				translate(grid(2, 1)) do(1, 3) Banana();
				translate(grid(2, 4)) Toggle();
			}
			translate([bx * 3, 0]) {
				// Comparator
				translate(grid(0, 0)) do(1, 3, sy = 2) Banana();
				translate(grid(0, 1)) do(1, 2, sy = 2) Pot();
				do(1, 2, sy = 3) led5(0.5, 0.5);
				translate(grid(1, 0)) do(1, 5) Banana();
			}
			translate([bx * 5, 0]) {
				// CV-Pro
				translate(grid(0, 0)) do(1, 2) Banana();
				translate(grid(0, 2)) Pot();
				translate(grid(0, 3)) do(1, 2) Banana();
				translate(grid(0.5, 0.5)) do(1, 2, sy = 3) Banana();
				translate(grid(1, 0)) do(1, 5) Toggle();
				translate(grid(2, 0)) do(1, 2) Pot();
				translate(grid(2, 2)) Toggle();
				translate(grid(2, 3)) do(1, 2) Pot();
			}
		}
	}

	module passivePaintjob() {
		translate(grid(0, 0)) unit(8, "PASSIVE ROUTER");
		translate(grid(0, 4)) frame(8, 1);
		do(8, 3) connect(0, 0.3, 0, 0.7);
	}

	module passivePanel() {
		3UPanel(42) {
			translate(grid(0, 0)) do(8, 3) Toggle();
			translate(grid(0, 3)) do(8, 2) Banana();
		}
	}

	module mixerPaintjob() {
		//do(8, 5) translate(grid(0, 0)) circle(d = 11.13);
		//do(7, 4) translate(grid(0.5, 0.5)) circle(d = 11.13);
		//do(8, 5) translate(grid(0, 0.5)) circle(d = 5);
		translate(grid(4, 0)) unit(4, "DUAL PROCESSOR");
		translate(grid(0, 0)) unit(4, "HOUSE SEQUENCER");

		translate([bx * 4, 0]) {
			do(4, 2) bipolar(0, 1);
			
			do(1, 1) label(3, 4, "OUT 1");
			do(1, 1) label(3, 3, "OUT 2");
			do(1, 2) label(3, 1, "± 5V");
		}

		translate([bx * 0, 0]) {
			label(0, 2, "RESET");
			label(1, 2, "CLOCK");
			label(2, 2, "HOLD");
			label(3, 2, "RESET");

			label(0, 1, "KICK");
			label(1, 1, "HAT");

			label(0.5, 0.5, "GATE");
			label(0.5, 1.5, "TRIG");

			do(2, 1)	 {
				d = 0.185;
				connect(1.5 + d, 0.5 + d, 2 - d, 1 - d);
				connect(1.5 + d, 1.5 - d, 2 - d, 1 + d);
			}
		}
	}

	module mixerPanel() {
		3UPanel(42) {
			translate([bx * 4, 0]) {
				translate(grid(0, 0)) do(4, 1) Toggle();
				translate(grid(0, 1)) do(4, 2) Pot();
				translate(grid(0, 3)) do(4, 2) Banana();
			}
			translate([bx * 0, 0]) {
				translate(grid(0, 3)) do(4, 2) Banana();
				translate(grid(0.0, 2.5)) do(4, 2) LED3();

				translate(grid(1, 2)) do(3, 1) Banana();
				translate(grid(0, 2)) do(1, 1) Toggle();

				translate(grid(0, 1)) do(4, 1) Banana();
				translate(grid(0.5, 0.5)) do(3, 2) Banana();

				translate(grid(0, 0)) do(4, 1) Toggle();
			}
		}
	}

	module cut() {
		color([0.9, 0.9, 0.9])
		linear_extrude(height = 2)
		children();
	}

	module fillet(r) {
	   offset(r = -r) {
	     offset(delta = r) {
	       children();
	     }
	   }
	}

	module paint() {
		color([0, 0, 0])
		translate([0, 0, 2])
		linear_extrude(height = 0.15)
		children();
	}

	module mill() {
		color([0.4, 0.4, 0.4])
		translate([0, 0, 2 + 0.01]) {
			union() {
				for(i = [0:3]) {
					dh = 1 / 20;
					translate([0, 0, -(i + 1) * dh])
					linear_extrude(height = dh)
					offset(delta = -i * dh)
					children();
				}		
			}
		}
	}


	translate([0, 0 * (3U + 4)]) {
		cut()
		mixerPanel();

		paint()
		mixerPaintjob();
	}

	
	translate([0, 1 * (3U + 4)]) {
		cut()
		panel();	
		
		paint()
		paintjob();
	}

	translate([0, 2 * (3U + 4)]) {
		cut()
		passivePanel();

		paint()
		passivePaintjob();
	}
	
}

Serge();
