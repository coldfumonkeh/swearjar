# swearjar

Profanity detection and filtering library for CFML applications

## Installation

    box install swearjar

## Usage

Instantiate the component:

    swearJar = new swearjar();

### swearjar.profane(text)

Returns true if the given string contains profanity.

    swearJar.profane( 'hello there' ); // false
    swearJar.profane( 'hello mother f-bomb' ); // true

### swearjar.censor(text)

Replaces profanity with asterisks.

    var clean = swearjar.censor( 'f-bomb you' ); // **** you

### swearjar.words(text)

Get the words alongside their categories.

    swearjar.words( 'fuck you john doe' ); // { fuck: ['sexual'] }
    
### swearjar.detailedProfane(text)

Get the words alongside their categories, count and a censored version of the text.

    swearjar.detailedProfane( 'fuck you john doe' );

returns:    
```
{
  categoryCount: {
    sexual: 1
  },
  censored: '**** you john doe',
  profane: true,
  wordCount: {
    fuck: 1
  },
  words: {
    fuck: [
      'sexual'
    ]
  }
}
```

### swearjar.scorecard(text)

Generates a report from the given text.

    swearjar.scorecard( 'f-bomb you' ); // {sexual: 1, inappropriate: 1}

### swearjar.addRegex(text)

Add a regex.

    swearjar.addRegex( 'addedword?\\b', ['detected'] );

### swearjar.addSimple(text)

Add a simple word.

    swearjar.addSimple( 'addedword', ['detected'] );

### swearjar.addEmoji(text)

Add an emoji word.

    swearjar.addEmoji( '1f596', ['detected'] );

### swearjar.loadBadWords(path)

Loads a dictionary of words to be used as filter.

NOTE: A US English default list located in the config directory is included and loaded by default.

    swearjar.loadBadWords( './config/profanity.json' );

A dictionary is just a plain JSON file containing an object where its keys are the words to check for and the values are arrays of categories where the words fall in.

```
{
  "regex": {
    "\\w*fuck\\w*": [
      "category1",
      "category2"
    ],
    "word2": [
      "category1"
    ],
    "word3": [
      "category2"
    ]
  },
  "simple": {
    "word1": [
      "category1",
      "category2"
    ],
    "word2": [
      "category1"
    ],
    "word3": [
      "category2"
    ]
  },
  "emoji": {
    "1f4a9": [
      "category1",
      "category2"
    ],
    "word2": [
      "category1"
    ],
    "word3": [
      "category2"
    ]
  }
}
```


## Acknowledgements

`swearjar` is based on [swearjar-node](https://github.com/ahmedengu/swearjar-node), which itself is based on [Swearjar](https://github.com/joshbuddy/swearjar) (Ruby) and [Swearjar PHP](https://github.com/raymondjavaxx/swearjar-php).