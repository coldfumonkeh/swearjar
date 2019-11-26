component extends="testbox.system.BaseSpec"{

    function beforeAll(){
        variables.libraryFilePath = expandPath( '../config/en_US.json' );
        variables.swearjar        = getMockBox().createMock( 'swearjar' ).init( libraryFilePath = variables.libraryFilePath );
    }

    function afterAll(){}

    function run(){

        describe( "The swearjar component", function(){

            describe( "Instantiating", function(){

                it( 'should return the correct component', function(){
                    expect( variables.swearjar )
                        .toBeTypeOf( 'component' )
                        .toBeInstanceOf( 'swearjar' );
                } );

                it( 'should contain the correct methods', function(){

                    makePublic( variables.swearjar, 'scan', 'scan' );

                    expect( variables.swearjar )
                        .toHaveKey( 'init' )
                        .toHaveKey( 'getBadWords' )
                        .toHaveKey( 'setBadWords' )
                        .toHaveKey( 'scan' )
                        .toHaveKey( 'profane' )
                        .toHaveKey( 'scorecard' )
                        .toHaveKey( 'words' )
                        .toHaveKey( 'censor' )
                        .toHaveKey( 'sugarcoat' )
                        .toHaveKey( 'unicorn' )
                        .toHaveKey( 'detailedProfane' )
                        .toHaveKey( 'addRegex' )
                        .toHaveKey( 'addSimple' )
                        .toHaveKey( 'addEmoji' )
                        .toHaveKey( 'loadBadWords' );

                } );

                it( 'should contain the default library JSON when instantiated', function(){

                    var result = variables.swearjar.getBadWords();
                    expect( result )
                        .toBeStruct()
                        .toHaveKey( 'regex' )
                        .toHaveKey( 'simple' )
                        .toHaveKey( 'emoji' );

                    expect( result[ 'simple' ] ).toHaveKey( 'anus' );
                    expect( result[ 'emoji' ] ).toHaveKey( '1f595' );


                } );

            } );

            describe( "Running Methods", function(){

                describe( "The profane method", function(){

                    it( 'should return the correct boolean value', function(){

                        var resultOne = variables.swearjar.profane( 'hello there' );
                        expect( resultOne ).toBeFalse();

                        var resultTwo = variables.swearjar.profane( 'hello mother fucker' );
                        expect( resultTwo ).toBeTrue();

                    } );

                } );

                describe( "The censor method", function(){

                    it( 'should return the string with the profanity censored', function(){

                        var resultOne = variables.swearjar.censor( 'fuck you' );
                        expect( resultOne )
                            .toBeString()
                            .toBe( '**** you' );

                        var resultTwo = variables.swearjar.censor( 'fuck you, you fucking stupid cunt!' );
                        expect( resultTwo )
                            .toBeString()
                            .toBe( '**** you, you ******* stupid ****!' );

                    } );

                } );

                describe( "The sugarcoat method", function(){

                    it( 'should return the string with the profanity replaced (if a replacement exists)', function(){

                        var resultOne = variables.swearjar.sugarcoat( 'Your life is like poor pornography' );
                        expect( resultOne )
                            .toBeString()
                            .toBe( 'Your life is like poor <span class="swearjar-sugarcoat">erotic literature</span>' );

                        var reaultTwo = variables.swearjar.sugarcoat(
                            text     = 'Your life is like poor pornography',
                            cssClass = 'dummy-class'
                        );
                        expect( reaultTwo )
                            .toBeString()
                            .toBe( 'Your life is like poor <span class="dummy-class">erotic literature</span>' );

                    } );

                } );

                describe( "The unicorn method", function(){

                    it( 'should return the string with the profanity replaced with unicorns', function(){

                        var resultOne = variables.swearjar.unicorn( 'fuck you, you fucking stupid cunt!' );
                        expect( resultOne )
                            .toBeString()
                            .toBe( 'unicorn you, you unicorn stupid unicorn!' );

                    } );

                } );

                describe( "The words method", function(){

                    it( 'should return the correct words with the associated categories', function(){

                        var result = variables.swearjar.words( 'fuck you' );
                        expect( result )
                            .toBeStruct()
                            .toHaveKey( 'fuck' );

                        expect( result[ 'fuck' ] ).toBeArray();

                    } );

                } );

                describe( "The detailedProfane method", function(){

                    it( 'should return the correct words with the associated categories, count and censored text', function(){

                        var result = variables.swearjar.detailedProfane( 'fuck you john doe' );
                        expect( result )
                            .toBeStruct()
                            .toHaveKey( 'categoryCount' )
                            .toHaveKey( 'censored' )
                            .toHaveKey( 'profane' )
                            .toHaveKey( 'wordCount' )
                            .toHaveKey( 'words' );

                        expect( result[ 'categoryCount' ] )
                            .toBeStruct()
                            .toHaveKey( 'sexual' );

                        expect( result[ 'censored' ] )
                            .toBeString()
                            .toBe( '**** you john doe' );

                        expect( result[ 'profane' ] ).toBeTrue()

                        expect( result[ 'wordCount' ] )
                            .toBeStruct()
                            .toHaveKey( 'fuck' );

                        expect( result[ 'words' ] )
                            .toBeStruct()
                            .toHaveKey( 'fuck' );

                        expect( result[ 'words' ][ 'fuck' ] ).toBeArray();

                    } );

                } );

                describe( "The scorecard method", function(){

                    it( 'should return a struct with a report from the given text', function(){

                        var result = variables.swearjar.scorecard( 'fuck you' );
                        expect( result )
                            .toBeStruct()
                            .toHaveKey( 'sexual' );

                    } );

                } );

                describe( "The addRegex method", function(){

                    it( 'should add a new regex entry into the stored library JSON', function(){

                        var badWords     = variables.swearjar.getBadWords();
                        var initialRegex = badWords[ 'regex' ];

                        expect( initialRegex ).toBeStruct();
                        expect( structKeyExists( initialRegex, 'addedword?\\b' ) ).toBeFalse();

                        var initialCount = structCount( initialRegex );

                        // Insert a new regex entry
                        variables.swearjar.addRegex( 'addedword?\\b', ['detected'] );

                        // Now fetch again and compare
                        var badWords     = variables.swearjar.getBadWords();
                        var updatedRegex = badWords[ 'regex' ];

                        expect( updatedRegex ).toBeStruct();

                        expect( structCount( updatedRegex ) ).toBe( initialCount + 1 );
                        expect( structKeyExists( updatedRegex, 'addedword?\\b' ) ).toBeTrue();

                    } );

                } );

                describe( "The addSimple method", function(){

                    it( 'should add a new simple word entry into the stored library JSON', function(){

                        var badWords     = variables.swearjar.getBadWords();
                        var initialSimple = badWords[ 'simple' ];

                        expect( initialSimple ).toBeStruct();
                        expect( structKeyExists( initialSimple, 'addedword' ) ).toBeFalse();

                        var initialCount = structCount( initialSimple );

                        // Insert a new simple entry
                        variables.swearjar.addSimple( 'addedword', ['detected'] );

                        // Now fetch again and compare
                        var badWords     = variables.swearjar.getBadWords();
                        var updatedSimple = badWords[ 'simple' ];

                        expect( updatedSimple ).toBeStruct();

                        expect( structCount( updatedSimple ) ).toBe( initialCount + 1 );
                        expect( structKeyExists( updatedSimple, 'addedword' ) ).toBeTrue();

                    } );

                } );

                describe( "The addEmoji method", function(){

                    it( 'should add a new emogi entry into the stored library JSON', function(){

                        var badWords     = variables.swearjar.getBadWords();
                        var initialEmoji = badWords[ 'emoji' ];

                        expect( initialEmoji ).toBeStruct();
                        expect( structKeyExists( initialEmoji, '1f596' ) ).toBeFalse();

                        var initialCount = structCount( initialEmoji );

                        // Insert a new emoji entry
                        variables.swearjar.addEmoji( '1f596', ['detected'] );

                        // Now fetch again and compare
                        var badWords     = variables.swearjar.getBadWords();
                        var updatedEmoji = badWords[ 'emoji' ];

                        expect( updatedEmoji ).toBeStruct();

                        expect( structCount( updatedEmoji ) ).toBe( initialCount + 1 );
                        expect( structKeyExists( updatedEmoji, '1f596' ) ).toBeTrue();

                    } );

                } );

                describe( "Loading a new library", function(){

                    it( 'should load up a new library file when calling the loadBadWords method', function(){

                        variables.swearjar.loadBadWords( expandPath( '../config/vintage.json' ) );

                        var result = variables.swearjar.getBadWords();
                        expect( result )
                            .toBeStruct()
                            .toHaveKey( 'regex' )
                            .toHaveKey( 'simple' )
                            .toHaveKey( 'emoji' );

                        expect( result[ 'regex' ] ).toHaveKey( '\w*ation\w*' );
                        expect( result[ 'simple' ] ).toHaveKey( 'rantallion' );

                    } );

                } );

            } );

        } );

    }

}