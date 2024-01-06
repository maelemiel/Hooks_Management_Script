SRC = main.c

$(NAME):
	gcc -o $(NAME) $(SRC)

all:
	$(NAME)

fclean:
	rm -f $(NAME)
	rm -f *.o