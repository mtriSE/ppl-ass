# How to use ?
1. In BKIT.g4, add your grammar
2. Run statements below to run

# Run statements
1. java -jar ./antlr-4.9.2-complete.jar BKIT.g4 
2. javac -classpath ./antlr-4.9.2-complete.jar BKIT*.java
3. java -cp ".:./antlr-4.9.2-complete.jar" org.antlr.v4.gui.TestRig BKIT program -gui input.txt