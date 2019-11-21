[![cfmlbadges](https://cfmlbadges.monkehworks.com/images/badges/available-on-forgebox.svg)](https://cfmlbadges.monkehworks.com) [![cfmlbadges](https://cfmlbadges.monkehworks.com/images/badges/compatibility-lucee-45.svg)](https://cfmlbadges.monkehworks.com) [![cfmlbadges](https://cfmlbadges.monkehworks.com/images/badges/compatibility-lucee-5.svg)](https://cfmlbadges.monkehworks.com) [![cfmlbadges](https://cfmlbadges.monkehworks.com/images/badges/compatibility-coldfusion-2018.svg)](https://cfmlbadges.monkehworks.com) [![cfmlbadges](https://cfmlbadges.monkehworks.com/images/badges/uses-cfml.svg)](https://cfmlbadges.monkehworks.com) [![cfmlbadges](https://cfmlbadges.monkehworks.com/images/badges/tested-with-testbox.svg)](https://cfmlbadges.monkehworks.com) [![cfmlbadges](https://cfmlbadges.monkehworks.com/images/badges/built-with-love.svg)](https://cfmlbadges.monkehworks.com) [![cfmlbadges](https://cfmlbadges.monkehworks.com/images/badges/kinda-sfw.svg)](https://cfmlbadges.monkehworks.com) [![cfmlbadges](https://cfmlbadges.monkehworks.com/images/badges/pretty-risque.svg)](https://cfmlbadges.monkehworks.com)

# swearjar

Profanity detection and filtering library for CFML applications

## Installation

This component can be installed as standalone or as a ColdBox Module. Either approach requires a simple CommandBox command:

```js
box install swearjar
```

### ColdBox Module
This package is also a ColdBox module. The module can be configured by creating a `swearjar` configuration structure in your application configuration file (`config/Coldbox.cfc`) with the following settings:

```js
swearjar = {
     libraryFilePath = '' // The path to your chosen profanity library JSON file
};
```
You can optionally leave this configuration out and `swearjar` will use the default `en_US.json` file.

Then you can inject the CFC via Wirebox:

```js
property name="swearjar" inject="swearjar@swearjar";
```

## Usage

Instantiate the component:
```js
swearJar = new swearjar();
```
### swearjar.profane(text)

Returns true if the given string contains profanity.
```js
swearJar.profane( 'hello there' ); // false
swearJar.profane( 'hello mother f-bomb' ); // true
```
### swearjar.censor(text)

Replaces profanity with asterisks.
```js
var clean = swearjar.censor( 'f-bomb you' ); // **** you
```

### swearjar.sugarcoat(text)

Replaces profanity with a replacement word, if one exists within the library file. If not, the word will be replaced with asterisks.
```js
var clean = swearjar.sugarcoat( 'Your life is like poor pornography' ); // Your life is like poor erotic literature
```

### swearjar.unicorn(text)

Replaces profanity with the word unicorn.
```js
var clean = swearjar.unicorn( 'fuck you, you fucking stupid cunt!' ); // unicorn you, you unicorn stupid unicorn!
```

### swearjar.words(text)

Get the words alongside their categories.
```js
swearjar.words( 'fuck you john doe' ); // { fuck: ['sexual'] }
```
### swearjar.detailedProfane(text)

Get the words alongside their categories, count and a censored version of the text.
```js
swearjar.detailedProfane( 'fuck you john doe' );
```
returns:    
```js
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
```js
swearjar.scorecard( 'f-bomb you' ); // {sexual: 1, inappropriate: 1}
```
### swearjar.addRegex(text)

Add a regex.
```js
swearjar.addRegex( 'addedword?\\b', ['detected'] );
```
### swearjar.addSimple(text)

Add a simple word.
```js
swearjar.addSimple( 'addedword', ['detected'] );
```
### swearjar.addEmoji(text)

Add an emoji word.
```js
swearjar.addEmoji( '1f596', ['detected'] );
```
### swearjar.loadBadWords(path)

Loads a dictionary of words to be used as filter.

NOTE: A US English default list located in the config directory is included and loaded by default.
```js
swearjar.loadBadWords( './config/profanity.json' );
```
A dictionary is just a plain JSON file containing an object where its keys are the words to check for and the values are arrays of categories where the words fall in.

```js
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
