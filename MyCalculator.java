import javax.swing.*;
import java.awt.BorderLayout;
import java.awt.GridLayout;
import java.awt.event.*;

public class MyCalculator {
    public static void main(String[] args) {
        Dentaku myCalculator = new Dentaku("上原の電卓");
        myCalculator.setBounds(100, 100, 500, 400); // Adjusting size for new buttons
        myCalculator.setVisible(true);
    }
}

class Dentaku extends JFrame {
    JLabel label = new JLabel("0");
    JLabel resultLabel1 = new JLabel("Result 1: ");
    JLabel resultLabel2 = new JLabel("Result 2: ");

    numBTN bt0 = new numBTN("0");
    numBTN bt1 = new numBTN("1");
    numBTN bt2 = new numBTN("2");
    numBTN bt3 = new numBTN("3");
    numBTN bt4 = new numBTN("4");
    numBTN bt5 = new numBTN("5");
    numBTN bt6 = new numBTN("6");
    numBTN bt7 = new numBTN("7");
    numBTN bt8 = new numBTN("8");
    numBTN bt9 = new numBTN("9");

    funBTN bt10 = new funBTN(".");
    funBTN bt11 = new funBTN("C");
    numBTN bt12 = new numBTN("00");
    funBTN bt13 = new funBTN("√");
    funBTN bt14 = new funBTN("x^2");

    funBTN btadd = new funBTN("＋");
    funBTN btsub = new funBTN("－");
    funBTN btmul = new funBTN("×");
    funBTN btdiv = new funBTN("÷");
    funBTN bteq = new funBTN("＝");

    // New function buttons
    funBTN btsin = new funBTN("sin");
    funBTN btcos = new funBTN("cos");
    funBTN bttan = new funBTN("tan");
    funBTN btfact = new funBTN("x!");
    funBTN btx3 = new funBTN("x^3");
    funBTN btx4 = new funBTN("x^4");
    funBTN btreciprocal = new funBTN("1/x");
    funBTN btexp = new funBTN("e^x");
    funBTN bt10powx = new funBTN("10^x");
    funBTN btx5 = new funBTN("x^5");
    funBTN bt3rootx = new funBTN("3√x");
    funBTN btpi = new funBTN("π");
    funBTN btln = new funBTN("ln");
    funBTN btlog10 = new funBTN("log10");
    funBTN bte = new funBTN("e");

    double operand1 = 0, operand2 = 0;
    String operator = "";
    boolean startNewNumber = true;
    boolean justCalculated = false;
    boolean isFirstResult = true;

    Dentaku(String str) {
        super(str);
        createDentaku();
    }

    void createDentaku() {
        JPanel display = new JPanel();
        JPanel body = new JPanel();
        JPanel numPanel = new JPanel();
        JPanel funPanel = new JPanel();
        JPanel resultPanel = new JPanel(); // New panel for results
        JPanel advFunPanel = new JPanel(); // New panel for advanced functions

        body.setLayout(new BorderLayout());
        body.add(numPanel, BorderLayout.CENTER);
        body.add(funPanel, BorderLayout.EAST);
        body.add(advFunPanel, BorderLayout.WEST); // Adding advanced functions panel to the left
        getContentPane().add(display, BorderLayout.NORTH);
        getContentPane().add(body, BorderLayout.CENTER);
        getContentPane().add(resultPanel, BorderLayout.SOUTH); // Adding result panel to the bottom

        setDisplay(display);
        setNumPanel(numPanel);
        setFunPanel(funPanel);
        setAdvFunPanel(advFunPanel); // Setting up the advanced function panel
        setResultPanel(resultPanel); // Setting up the result panel
    }

    void setDisplay(JPanel p) {
        p.add(label);
    }

    void setNumPanel(JPanel p) {
        p.setLayout(new GridLayout(5, 3));
        p.add(bt11);
        p.add(bt14);
        p.add(bt13);
        p.add(bt7);
        p.add(bt8);
        p.add(bt9);
        p.add(bt4);
        p.add(bt5);
        p.add(bt6);
        p.add(bt1);
        p.add(bt2);
        p.add(bt3);
        p.add(bt0);
        p.add(bt12);
        p.add(bt10);
    }

    void setFunPanel(JPanel p) {
        p.setLayout(new GridLayout(5, 1));
        p.add(btadd);
        p.add(btsub);
        p.add(btmul);
        p.add(btdiv);
        p.add(bteq);
    }

    void setAdvFunPanel(JPanel p) {
        p.setLayout(new GridLayout(5, 3));
        p.add(btsin);
        p.add(btcos);
        p.add(bttan);
        p.add(btfact);
        p.add(btx3);
        p.add(btx4);
        p.add(btreciprocal);
        p.add(btexp);
        p.add(bt10powx);
        p.add(btx5);
        p.add(bt3rootx);
        p.add(btpi);
        p.add(btln);
        p.add(btlog10);
        p.add(bte);
    }

    void setResultPanel(JPanel p) {
        p.setLayout(new GridLayout(2, 1));
        p.add(resultLabel1);
        p.add(resultLabel2);
    }

    void updateResults(double result) {
        if (isFirstResult) {
            resultLabel1.setText("<html>Result 1: <b>" + result + "</b></html>");
        } else {
            resultLabel2.setText("<html>Result 2: <b>" + result + "</b></html>");
        }
        isFirstResult = !isFirstResult;
    }

    double factorial(double n) {
        if (n == 0) return 1;
        return n * factorial(n - 1);
    }

    class numBTN extends JButton implements ActionListener {
        public numBTN(String label) {
            super(label);
            this.addActionListener(this);
        }

        public void actionPerformed(ActionEvent e) {
            String str = this.getText();
            if (startNewNumber || justCalculated) {
                label.setText(str);
                startNewNumber = false;
                justCalculated = false;
            } else {
                label.setText(label.getText() + str);
            }
        }
    }

    class funBTN extends JButton implements ActionListener {
        funBTN(String label) {
            super(label);
            this.addActionListener(this);
        }

        public void actionPerformed(ActionEvent e) {
            String cmd = this.getText();
            switch (cmd) {
                case "＋":
                case "－":
                case "×":
                case "÷":
                    operator = cmd;
                    operand1 = Double.parseDouble(label.getText());
                    startNewNumber = true;
                    justCalculated = false;
                    break;
                case "＝":
                    operand2 = Double.parseDouble(label.getText());
                    double result = 0;
                    switch (operator) {
                        case "＋":
                            result = operand1 + operand2;
                            break;
                        case "－":
                            result = operand1 - operand2;
                            break;
                        case "×":
                            result = operand1 * operand2;
                            break;
                        case "÷":
                            if (operand2 == 0) {
                                result = 0; // Divide by zero case
                            } else {
                                result = operand1 / operand2;
                            }
                            break;
                    }
                    label.setText(String.valueOf(result));
                    updateResults(result);
                    startNewNumber = true;
                    justCalculated = true;
                    operand1 = 0;
                    operand2 = 0;
                    operator = "";
                    break;
                case "√":
                    operand1 = Double.parseDouble(label.getText());
                    double sqrtResult = Math.sqrt(operand1);
                    label.setText(String.valueOf(sqrtResult));
                    updateResults(sqrtResult);
                    startNewNumber = true;
                    justCalculated = true;
                    break;
                case "x^2":
                    operand1 = Double.parseDouble(label.getText());
                    double squareResult = operand1 * operand1;
                    label.setText(String.valueOf(squareResult));
                    updateResults(squareResult);
                    startNewNumber = true;
                    justCalculated = true;
                    break;
                case "sin":
                    operand1 = Double.parseDouble(label.getText());
                    double sinResult = Math.sin(Math.toRadians(operand1));
                    label.setText(String.valueOf(sinResult));
                    updateResults(sinResult);
                    startNewNumber = true;
                    justCalculated = true;
                    break;
                case "cos":
                    operand1 = Double.parseDouble(label.getText());
                    double cosResult = Math.cos(Math.toRadians(operand1));
                    label.setText(String.valueOf(cosResult));
                    updateResults(cosResult);
                    startNewNumber = true;
                    justCalculated = true;
                    break;
                case "tan":
                    operand1 = Double.parseDouble(label.getText());
                    double tanResult = Math.tan(Math.toRadians(operand1));
                    label.setText(String.valueOf(tanResult));
                    updateResults(tanResult);
                    startNewNumber = true;
                    justCalculated = true;
                    break;
                case "x!":
                    operand1 = Double.parseDouble(label.getText());
                    double factResult = factorial(operand1);
                    label.setText(String.valueOf(factResult));
                    updateResults(factResult);
                    startNewNumber = true;
                    justCalculated = true;
                    break;
                case "x^3":
                    operand1 = Double.parseDouble(label.getText());
                    double x3Result = Math.pow(operand1, 3);
                    label.setText(String.valueOf(x3Result));
                    updateResults(x3Result);
                    startNewNumber = true;
                    justCalculated = true;
                    break;
                case "x^4":
                    operand1 = Double.parseDouble(label.getText());
                    double x4Result = Math.pow(operand1, 4);
                    label.setText(String.valueOf(x4Result));
                    updateResults(x4Result);
                    startNewNumber = true;
                    justCalculated = true;
                    break;
                case "1/x":
                    operand1 = Double.parseDouble(label.getText());
                    double reciprocalResult = 1 / operand1;
                    label.setText(String.valueOf(reciprocalResult));
                    updateResults(reciprocalResult);
                    startNewNumber = true;
                    justCalculated = true;
                    break;
                case "e^x":
                    operand1 = Double.parseDouble(label.getText());
                    double expResult = Math.exp(operand1);
                    label.setText(String.valueOf(expResult));
                    updateResults(expResult);
                    startNewNumber = true;
                    justCalculated = true;
                    break;
                case "10^x":
                    operand1 = Double.parseDouble(label.getText());
                    double tenPowResult = Math.pow(10, operand1);
                    label.setText(String.valueOf(tenPowResult));
                    updateResults(tenPowResult);
                    startNewNumber = true;
                    justCalculated = true;
                    break;
                case "x^5":
                    operand1 = Double.parseDouble(label.getText());
                    double x5Result = Math.pow(operand1, 5);
                    label.setText(String.valueOf(x5Result));
                    updateResults(x5Result);
                    startNewNumber = true;
                    justCalculated = true;
                    break;
                case "3√x":
                    operand1 = Double.parseDouble(label.getText());
                    double root3Result = Math.cbrt(operand1);
                    label.setText(String.valueOf(root3Result));
                    updateResults(root3Result);
                    startNewNumber = true;
                    justCalculated = true;
                    break;
                case "π":
                    label.setText(String.valueOf(Math.PI));
                    startNewNumber = true;
                    justCalculated = false;
                    break;
                case "ln":
                    operand1 = Double.parseDouble(label.getText());
                    double lnResult = Math.log(operand1);
                    label.setText(String.valueOf(lnResult));
                    updateResults(lnResult);
                    startNewNumber = true;
                    justCalculated = true;
                    break;
                case "log10":
                    operand1 = Double.parseDouble(label.getText());
                    double log10Result = Math.log10(operand1);
                    label.setText(String.valueOf(log10Result));
                    updateResults(log10Result);
                    startNewNumber = true;
                    justCalculated = true;
                    break;
                case "e":
                    label.setText(String.valueOf(Math.E));
                    startNewNumber = true;
                    justCalculated = false;
                    break;
                case ".":
                    if (startNewNumber || justCalculated) {
                        label.setText("0.");
                        startNewNumber = false;
                        justCalculated = false;
                    } else if (!label.getText().contains(".")) {
                        label.setText(label.getText() + ".");
                    }
                    break;
                case "C":
                    label.setText("0");
                    operand1 = 0;
                    operand2 = 0;
                    operator = "";
                    startNewNumber = true;
                    justCalculated = false;
                    break;
            }
        }
    }
}


