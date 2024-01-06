SRC = src/main.c

NAME = test_name

$(NAME):
	gcc -o $(NAME) $(SRC)

all:
	$(NAME)

fclean:
	rm -f $(NAME)
	rm -f *.o

test:
	echo "test"

re: fclean all
