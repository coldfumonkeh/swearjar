/**
 * Name: swearjar.cfc
 * Author: Matt Gifford (matt@monkehworks.com)
 * Purpose: A CFML profanity detection and filtering component library
 */
component accessors="true" singleton {

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
        string cssClass = '',
        required any callback
    ){
        var stuBadWords  = getBadWords();
        var arrNoMatches = [];
        var arrMatches   = reMatchNoCase( '\w+', arguments.text );

        for( var index = 1; index <= arrayLen( arrMatches ); index++ ){
            var word = arrMatches[ index ];
            var key  = lcase( word );
            if( structKeyExists( stuBadWords[ 'simple' ], key ) && isArray( stuBadWords[ 'simple' ][ key ] ) ){
                var replacements = ( structKeyExists( stuBadWords[ 'replacements' ], key ) ) ? stuBadWords[ 'replacements' ][ key ] : [];
                if( callback( word, index, stuBadWords[ 'simple' ][ key ], replacements, arguments.cssClass, 'simple' ) EQ false ){
                    break;
                }
            } else if( structKeyExists( stuBadWords[ 'emoji' ], key ) && isArray( stuBadWords[ 'emoji' ][ key ] ) ){
                var replacements = ( structKeyExists( stuBadWords[ 'replacements' ], key ) ) ? stuBadWords[ 'replacements' ][ key ] : [];
                if( callback( word, index, stuBadWords[ 'emoji' ][ regexString ], replacements, 'emoji' ) EQ false ){
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
                var replacements = ( structKeyExists( stuBadWords[ 'replacements' ], word ) ) ? stuBadWords[ 'replacements' ][ word ] : [];
                if( callback( word, index, stuBadWords[ 'regex' ][ regexString ], replacements, 'regex' ) EQ false ){
                    break;
                }
            }
        }
    }

    private string function stripUnsafeSpace(required string text){
        return javacast("string", arguments.text).replaceAll("#chr(1)#|&##1;|&##xf0001;|#chr(2)#|&##2;|&##xf0002;|#chr(3)#|&##3;|&##xf0003;|#chr(4)#|&##4;|&##xf0004;|#chr(5)#|&##5;|&##xf0005;|#chr(6)#|&##6;|&##xf0006;|#chr(7)#|&##7;|&##xf0007;|#chr(8)#|&##8;|&##xf0008;|#chr(11)#|&##11;|&##xf000b;|#chr(12)#|&##12;|&##xf000c;|#chr(14)#|&##14;|&##xf000e;|#chr(15)#|&##15;|&##xf000f;|#chr(16)#|&##16;|&##xf0010;|#chr(17)#|&##17;|&##xf0011;|#chr(18)#|&##18;|&##xf0012;|#chr(19)#|&##19;|&##xf0013;|#chr(20)#|&##20;|&##xf0014;|#chr(21)#|&##21;|&##xf0015;|#chr(22)#|&##22;|&##xf0016;|#chr(23)#|&##23;|&##xf0017;|#chr(24)#|&##24;|&##xf0018;|#chr(25)#|&##25;|&##xf0019;|#chr(26)#|&##26;|&##xf001a;|#chr(27)#|&##27;|&##xf001b;|#chr(28)#|&##28;|&##xf001c;|#chr(29)#|&##29;|&##xf001d;|#chr(30)#|&##30;|&##xf001e;|#chr(31)#|&##31;|&##xf001f;|#chr(133)#|&##133;|&##xf0085;|#chr(160)#|&##160;|&##xf00a0;|#chr(5760)#|&##5760;|&##xf1680;|#chr(6158)#|&##6158;|&##xf180e;|#chr(8192)#|&##8192;|&##xf2000;|#chr(8193)#|&##8193;|&##xf2001;|#chr(8194)#|&##8194;|&##xf2002;|#chr(8195)#|&##8195;|&##xf2003;|#chr(8196)#|&##8196;|&##xf2004;|#chr(8197)#|&##8197;|&##xf2005;|#chr(8198)#|&##8198;|&##xf2006;|#chr(8199)#|&##8199;|&##xf2007;|#chr(8200)#|&##8200;|&##xf2008;|#chr(8201)#|&##8201;|&##xf2009;|#chr(8202)#|&##8202;|&##xf200a;|#chr(8203)#|&##8203;|&##xf200b;|‌#chr(8204)#|&##8204;|&##xf200c;|‍#chr(8205)#|&##8205;|&##xf200d;|#chr(8206)#|&##8206;|&##xf200e;|#chr(8207)#|&##8207;|&##xf200f;|⁠#chr(8288)#|&##8288;|&##xf2060;|#chr(8232)#|&##8232;|&##xf2028;|#chr(8233)#|&##8233;|&##xf2029;|#chr(8239)#|&##8239;|&##xf202f;|#chr(8287)#|&##8287;|&##xf205f;|#chr(9248)#|&##9248;|&##xf2420;|#chr(9250)#|&##9250;|&##xf2422;|#chr(9251)#|&##9251;|&##xf2423;|#chr(10240)#|&##10240;|&##xf2800;|#chr(12288)#|&##12288;|&##xf3000;|#chr(65279)#|&##65279;|&##xffeff;|#chr(96296)#|&##65296;|&##xfff10;", "");
    }

    /**
	 * Returns true if `text` contains profanity
	 *
	 * @param string text
	 * @return boolean
	 */
    public boolean function profane( required string text ){
        var profane = false;
        this.scan( text = stripUnsafeSpace(arguments.text), callback = function( word, index, categories ){
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
        this.scan( text = stripUnsafeSpace(arguments.text), callback = function( word, index, categories ){
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
        this.scan( text = stripUnsafeSpace(arguments.text), callback = function( word, index, categories ){
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
        var censored = stripUnsafeSpace(arguments.text);
        this.scan( text = stripUnsafeSpace(arguments.text), callback = function( word, index, categories ){
            censored = replaceNoCase( censored, word, reReplaceNoCase( word, '[a-z]', '*', 'all' ) );
        } );
        return censored;
    }

    /**
     * Replaces any profanity within `text` with a given replacement, if one exists in the library. If not, it will be replaced with asterisks
     *
     * @param string text
     * @returns string
     */
    public string function sugarcoat(
        required string text,
        string cssClass = 'swearjar-sugarcoat'
    ){
        var censored = stripUnsafeSpace(arguments.text);
        this.scan( text = stripUnsafeSpace(arguments.text), cssClass = arguments.cssClass, callback = function( word, index, categories, replacements, cssClass ){
            if( arrayLen( replacements ) ){
                var repIndex = ( arrayLen( replacements ) > 1 ) ? randRange( 1, arrayLen( replacements ) ) : 1;
                var replacement = '<span class="#cssClass#">#replacements[ repIndex ]#</span>';
            } else {
                var replacement = reReplaceNoCase( word, '[a-z]', '*', 'all' );
            }
            censored = replaceNoCase( censored, word, replacement );
        } );
        return censored;
    }

    /**
     * Replaces any profanity within `text` with the word `unicorn`
     *
     * @param string text
     * @returns string
     */
    public string function unicorn( required string text ){
        var censored = stripUnsafeSpace(arguments.text);
        this.scan( text = stripUnsafeSpace(arguments.text), callback = function( word, index, categories ){
            censored = replaceNoCase( censored, word, 'unicorn' );
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
        var censored      = stripUnsafeSpace(arguments.text);
        var profane       = false;
        var words         = {};
        var categoryCount = {};
        var wordCount     = {};
        this.scan( text = stripUnsafeSpace(arguments.text), callback = function( word, index, categories ){
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
