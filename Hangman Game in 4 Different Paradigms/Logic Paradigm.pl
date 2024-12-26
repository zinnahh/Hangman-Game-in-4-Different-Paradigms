:- dynamic guessed/1.

% Main entry point for the hangman game
hangman :-
    retractall(guessed(_)), % Clear guessed letters from previous games
    random_word(Word),
    play(Word, 6).

% List of possible words
word_list(['richard', 'jewel', 'xyrujun', 'casey', 'jezrelle', 'zynnah']).

% Select a random word from the list
random_word(Word) :-
    word_list(Words),
    random_member(Word, Words).

% Main game loop
play(Word, Attempts) :-
    display_word(Word),
    format('Attempts remaining: ~w~n', [Attempts]),
    (   Attempts > 0 -> % Continue game if attempts are available
        read_input(Letter),
        (   guessed(Letter) -> % Check if the letter was already guessed
            write('You already guessed that letter!'), nl,
            play(Word, Attempts)
        ;   assert(guessed(Letter)),
            (   sub_string(Word, _, 1, _, Letter) -> % Correct guess
                write('Correct guess!'), nl,
                (   all_guessed(Word) -> % Check if all letters are guessed
                    format('Congratulations! You guessed the word: ~w.~n', [Word])
                ;   play(Word, Attempts)
                )
            ;   % Incorrect guess
                NewAttempts is Attempts - 1,
                write('Incorrect guess!'), nl,
                play(Word, NewAttempts)
            )
        )
    ;   % Game over condition
        format('Game over! The word was: ~w.~n', [Word])
    ).

% Display the current state of the word
display_word(Word) :-
    findall(Char, (sub_string(Word, _, 1, _, Char), (guessed(Char) -> Char; Char = '_')), Display),
    atomic_list_concat(Display, ' ', DisplayString),
    write('Guess the word: '), write(DisplayString), nl.

% Validate input and ensure it is a single character
read_input(Letter) :-
    write('Enter a letter: '),
    read(UserInput),
    (   atom(UserInput),
        atom_length(UserInput, 1) -> % Ensure input is a single character
            downcase_atom(UserInput, Letter) % Convert to lowercase
    ;   write('Invalid input. Please enter a single letter.'), nl,
        read_input(Letter)
    ).

% Check if all letters in the word have been guessed
all_guessed(Word) :-
    string_chars(Word, CharList),
    forall(member(Char, CharList), guessed(Char)).
