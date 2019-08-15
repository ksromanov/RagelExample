lexer: lexer.cpp
	g++ -o lexer lexer.cpp

lexer.cpp: lexer.rl
	ragel -G2 -s -o lexer.cpp lexer.rl
