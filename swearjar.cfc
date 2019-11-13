/**
 * Name: swearjar.cfc
 * Author: Matt Gifford (matt@monkehworks.com)
 * Purpose: A CFML profanity detection and filtering component library
 */
component accessors="true" {

    property name="badWords" type="struct";

    /**
     * Constructor method
     * 
     * @param string libraryFilePath
     */
    public swearjar function init(
        string libraryFilePath = './config/en_US.json'
    ){
        this.loadBadWords( arguments.libraryFilePath );
        return this;
    }

    /**
	 * Scans `text` looking for profanity. The callback is invoked on
	 * each instance of the profanity.
	 *
	 * The signature of `callback` is:
	 * 
	 *    function (word, index, categories) { ... }
	 * 
	 * Where `word` is the possible profane word, `index` is the offset of the word
	 * in the text, and `categories` is a list of tags for the word.
	 * 
	 * @param string text
	 * @param closure callback
	 * @return void
	 */
    private void function scan(
        required string text,
        required any callback
    ){
        var stuBadWords  = getBadWords();
        var arrNoMatches = [];
        var arrMatches   = reMatchNoCase( '\w+', arguments.text );

        for( var index = 1; index <= arrayLen( arrMatches ); index++ ){
            var word = arrMatches[ index ];
            var key  = lcase( word );
            if( structKeyExists( stuBadWords[ 'simple' ], key ) && isArray( stuBadWords[ 'simple' ][ key ] ) ){
                if( callback( word, index, stuBadWords[ 'simple' ][ key ], 'simple' ) EQ false ){
                    break;
                }
            } else if( structKeyExists( stuBadWords[ 'emoji' ], key ) && isArray( stuBadWords[ 'emoji' ][ key ] ) ){
                if( callback( word, index, stuBadWords[ 'emoji' ][ regexString ], 'emoji' ) EQ false ){
                    break;
                }
            } else {
                arrayAppend( arrNoMatches, key );
            }
        }

        var jopinedText = arrayToList( arrNoMatches, ' ' );
        for( var regexString in stuBadWords[ 'regex' ] ){
            var arrRegMatches = reMatchNoCase( regexString, jopinedText );
            for( var index = 1; index <= arrayLen( arrRegMatches ); index++ ){
                var word = arrRegMatches[ index ];
                if( callback( word, index, stuBadWords[ 'regex' ][ regexString ], 'regex' ) EQ false ){
                    break;
                }
            }
        }
    }

    /**
	 * Returns true if `text` contains profanity
	 *
	 * @param string text
	 * @return boolean
	 */
    public boolean function profane( required string text ){
        var profane = false;
        this.scan( arguments.text, function( word, index, categories ){
            profane = true;
            return false; // stop on first match
        } );
        return profane;
    }

    /**
	 * Analyzes `text` and generates a report of the type of profanity found.
	 *
	 * @param string text
	 * @return struct
	 */
    public struct function scorecard( required string text ){
        var scorecard = {};
        this.scan( arguments.text, function( word, index, categories ){
            for( var i = 1; i <= arrayLen( arguments.categories ); i++ ){
                var cat = arguments.categories[ i ];
                if( structKeyExists( scorecard, cat ) ){
                    scorecard[ cat ] = scorecard[ cat ]+1;
                } else {
                    scorecard[ cat ] = 1;
                }
            }
        } );
        return scorecard;
    }

    /**
     * Get the words alongside their categories.
     *
     * @param string text
     * @returns struct 
     */
    public struct function words( required string text ){
        var words = {};
        this.scan( arguments.text, function( word, index, categories ){
            words[ arguments.word ] = arguments.categories;
        } );
        return words;
    }

    /**
     * Replaces any profanity within `text` with asterisks
     *
     * @param string text
     * @returns string
     */
    public string function censor( required string text ){
        var censored = arguments.text;
        this.scan( arguments.text, function( word, index, categories ){
            censored = replaceNoCase( censored, word, reReplaceNoCase( word, '[a-z]', '*', 'all' ) );
        } );
        return censored;
    }

    /**
     * Analyzes `text` and generates a structural response with the word categories, count and censored text
     *
     * @param string text
     * @return struct
     */
    public struct function detailedProfane( required string text ){
        var censored      = arguments.text;
        var profane       = false;
        var words         = {};
        var categoryCount = {};
        var wordCount     = {};
        this.scan( arguments.text, function( word, index, categories ){
            profane = true;
            words[ arguments.word ] = arguments.categories;
            censored = replaceNoCase( censored, arguments.word, reReplaceNoCase( arguments.word, '[a-z]', '*', 'all' ) );
            for( var i = 1; i <= arrayLen( arguments.categories ); i++ ){
                var cat = arguments.categories[ i ];
                if( structKeyExists( categoryCount, cat ) ){
                    categoryCount[ cat ] = categoryCount[ cat ] + 1;
                } else {
                    categoryCount[ cat ] = 1;
                }
            }
            if( structKeyExists( wordCount, arguments.word ) ){
                wordCount[ arguments.word ] = wordCount[ arguments.word ] + 1;
            } else {
                wordCount[ arguments.word ] = 1;
            }
        } );
        return {
            'censored'     : censored,
            'profane'      : profane,
            'categoryCount': categoryCount,
            'wordCount'    : wordCount,
            'words'        : words
        };
    }

    /**
     * Add a regex to the stored list of bad words persisted by the component.
     *
     * @param string word 
     * @param array or string categories 
     * @returns void
     */
    public void function addRegex(
        required string word,
        required any categories
    ){
        var badWords = getBadWords();
        var categoryArray = ( isArray( arguments.categories ) ) ? arguments.categories : [ arguments.categories ];
        if( structKeyExists( badWords[ 'regex' ], arguments.word ) ){
            arrayAppend( badWords[ 'regex' ][ arguments.word ], categoryArray, true );
        } else {
            badWords[ 'regex' ][ arguments.word ] = categoryArray;
        }
    }        
    
    /**
     * Add a simple word to the stored list of bad words persisted by the component.
     *
     * @param string word 
     * @param array or string categories
     * @returns void 
     */
    public void function addSimple(
        required string word,
        required any categories
    ){
        var badWords = getBadWords();
        var categoryArray = ( isArray( arguments.categories ) ) ? arguments.categories : [ arguments.categories ];
        if( structKeyExists( badWords[ 'simple' ], arguments.word ) ){
            arrayAppend( badWords[ 'simple' ][ arguments.word ], categoryArray, true );
        } else {
            badWords[ 'simple' ][ arguments.word ] = categoryArray;
        }
        setBadWords( badWords );
    }
    
    /**
     * Add an emoji word to the stored list of bad words persisted by the component.
     *
     * @param string word 
     * @param array or string categories 
     * @returns void
     */
    public void function addEmoji(
        required string word,
        required any categories
    ){
        var badWords = getBadWords();
        var categoryArray = ( isArray( arguments.categories ) ) ? arguments.categories : [ arguments.categories ];
        if( structKeyExists( badWords[ 'emoji' ], arguments.word ) ){
            arrayAppend( badWords[ 'emoji' ][ arguments.word ], categoryArray, true );
        } else {
            badWords[ 'emoji' ][ arguments.word ] = categoryArray;
        }
        setBadWords( badWords );
    }

    /**
     * Loads a dictionary of words to be used as the filter.
     *
     * @param string relativePath
     * @returns void
     */
    public void function loadBadWords( required string relativePath ){
        setBadWords( deserializeJSON( fileRead( arguments.relativePath ) ) );
    }

}