import java.io.*;
import java.awt.*;
import java.awt.event.*;
import java.applet.*;
import java.net.*;
import java.util.Calendar;
import java.util.Date;

public class wheel {

    static public void main (String Args[]) {
	Picture p = new Picture();
        p.show();
    }

}

class Picture extends Frame {

    Picture() {
        setSize(500,500);
        setVisible(true);
        repaint();
    }
    
    int size = 0;
    int border = 30;
    
    int x(double xx) {
	return ((int) (size*(xx+1)/2)+border);
    }

    double h = 0.3;

    double cos(double x) {
	return java.lang.Math.cos(x);
    }  

    double sqrt(double x) {
	return java.lang.Math.sqrt(x);
    }  

    double sin(double x) {
	return java.lang.Math.sin(x);
    }  

    double acos(double x) {
	return java.lang.Math.acos(x);
    }  

    public void paint (Graphics g) {
	int height = getSize().height;
	int width = getSize().width;
        size = height;
        if (width < height) {
	    size = width;
	}
        size = size - 2*border;
	Font fs = new Font("TimesRoman", Font.BOLD,20);
	g.setFont(fs);
        g.setColor(Color.white);
        g.fillRect(0,0,width,height);
        int[][] xs = new int[2][4];
        xs[0][0] = x(0.0);
        xs[1][0] = x(0.0);
        xs[0][1] = x(-sqrt(1-h*h));
        xs[0][3] = x(0.0);
        xs[0][2] = x(sqrt(1-h*h));
        xs[1][1] = xs[1][2] = xs[1][3] = x(h);
        g.setColor(new Color(200,200,250));
        g.fillOval(x(-1.0),x(-1.0),2*(x(1.0)-x(0)),2*(x(1.0)-x(0.0)));
        g.setColor(new Color(220,220,220));
        g.fillOval(x(-h),x(-h),2*(x(h)-x(0)),2*(x(h)-x(0)));
        g.setColor(new Color(0,0,200));
        int R = (x(1.0)-x(0.0))*(x(1.0)-x(0.0));
	for (int j = xs[1][1]; j < height; j++) {
	    for (int i = xs[0][1]; i < width; i++) {
		if ((i-xs[0][0])*(i-xs[0][0])+(j-xs[0][0])*(j-xs[0][0]) < R) {
		    g.fillRect(i,j,1,1);
		}
	    }
	}
	g.setColor(Color.black);
        g.drawOval(x(-1.0),x(-1.0),size,size);
        g.drawLine(xs[0][0],xs[1][0],xs[0][1],xs[1][1]);
        g.drawLine(xs[0][0],xs[1][0],xs[0][2],xs[1][2]);
        g.drawLine(xs[0][0],xs[1][0],xs[0][3],xs[1][3]);
        g.drawLine(xs[0][1],xs[1][1],xs[0][2],xs[1][2]);
        int n = 100;
        for (int i = 0; i < n; i++) {
	    double phi = ((double) i)/((double) n)*acos(h) + java.lang.Math.acos(0.0);
            int xx = x(h/2*cos(phi));
	    int yy = x(h/2*sin(phi));
            g.fillRect(xx,yy,1,1);
	}
        g.drawString("t",x(-h/2),x(h/2));
	
        g.drawString("h",x(0.04),x(2*h/3));
        g.drawString("dry",x(-0.1),x(-h/3));
        g.drawString("r",x(0.5),x(h/2));
        g.drawString("Evaporation",x(-0.4),x(-0.5));
        g.drawString("W",x(0.6),x(-0.6));
        g.setColor(Color.white);
        g.drawString("water",x(-0.1),x(1.5*h));
    }
}

