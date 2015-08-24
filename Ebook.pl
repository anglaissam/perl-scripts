#!/usr/bin/perl -w
#Last Edit: 5/14/14

#             Ebook cleaning perl script - Designed for books just converted from doc/text to html

#=======================================================================================================================
    # Usage
    #=======================================================================================================================
    # Input: Specify a directory to run script on. Default is directory script is placed in. Can specify specific directory/file
    # Output: Modifies all htm/html files in directory
#=======================================================================================================================

#=======================================================================================================================
    # Notes
    #=======================================================================================================================
    # The following are conditions that need to be met in order for the script to work 100%
    #      - Title must be <H1>
    #      - Author must be on the next line, preferably <H2>
    # The following is needed to make the script work:
    #  ActivePerl - the perl binaries
    #  Tidy - Directory needs to be check and modified in script if changed
    #        - Tidy is called twice in the script
    #        - Config file must have large word-wrap number otherwise will cause problems
    # The following are things needed to help with ebooks
    #  Wordmagus  - Used to convert files to html
    #  tidy.bat  - create a batch file that can execute basic tidy through right clicking htm/html files
    #
#=======================================================================================================================
use File::Basename qw(dirname basename);
select((select(STDOUT), $| = 1)[0]); #Removes buffering to STDOUT so perl will print when needed.
#DEBUG: Switch sections off and on [0/1]
$section1 = 1;     #First
$section2 = 1;     #Head
$section3 = 1;    #Scripting/Cleanup
$section4 = 1;    #General Errors
$section5 = 1;     #Specific Errors
$section6 = 1;     #Other
$repeatloop = 1;    #Loop until no more changes occur.
$secondloop = 1;    #Second Loop for fixing Summary
#=======================================================================================================================
    # Single Variables
#=======================================================================================================================
$start = time(); #Timer
$debug = "C:\\Users\\Admin\\Documents\\Ebooks\\Unsorted\\Temp\\debug.txt";
$hrbreak = "<P CLASS=\"a1\">~&laquo; &laquo;&lsaquo;&sect;&rsaquo;&raquo; &raquo;~</P>";
$bookend = "<P CLASS=\"a1\">&lsaquo;~&dagger;~&rsaquo; &tau;&epsilon;&lambda;&omicron;&sigmaf; &lsaquo;~&dagger;~&rsaquo;</P>\n</BODY>";
$sstring = "<P CLASS=\"a1\"><STRONG>Summary:<\/STRONG> <\/P>";
$css = " h1, h2 {text-align: center}\n p.a1 {text-align: center}";
$icon_name = 'favicon.ico'; #Used to add favicon link to ebook
$bookendcheck = 'false';
$scriptcheck = 'false';
$csscheck1 = 'false';
$csscheck2 = 'false';
$postbody = 'false';
$extensionHTML = 'false';
$del = '~!!DELETE THIS LINE!!~';    #Variable is used to delete unwanted lines in script;
$status = 0;
$i = 0;
$loop = 0;
$f = '';
$f_2 = ''; #f2 created for when $f contains '&' which causes problems when creating the <TITLE> element.
$ftotal = 0; #number of html files in array
$fcount = 0; #position of currently processed book in array
$forig = ''; #String containing entire original document for comparison
$fnew = ''; #New modified doc for comparison
#=======================================================================================================================

#=======================================================================================================================
    # Multi-Line Variables
#=======================================================================================================================
$script = <<END;
    <SCRIPT TYPE="text/javascript">
    <!--
    BackColor="000000";
    TextColor="FFFFFF";
    FontType="Verdana";
    
    function resetColors() {
    var str='';
    str+='BackColor="'+BackColor+'";';
    str+='TextColor="'+TextColor+'";';
    str+='FontType="'+FontType+'";';
    // trying the top frameset
    if (self.location!=top.location) top.savedDocumentColors=str;
    // trying a cookie
    else document.cookie="savedDocumentColors="+escape(str);
    var theURL=''+self.location;
    var ind=theURL.indexOf('#')
    if (ind!=-1) theURL=theURL.substring(0,ind);
    self.location=theURL;
    }
    function readColors() {
    if (top.savedDocumentColors) { eval(''+top.savedDocumentColors); return; }
    else {
    var theCookie=''+document.cookie;
    var ind=theCookie.indexOf('savedDocumentColors');
    if (ind==-1) return;
    var ind1=theCookie.indexOf(';',ind);
    if (ind1==-1) ind1=theCookie.length;
    eval(''+unescape(theCookie.substring(ind+20,ind1)));
    }
    }
    readColors();
    document.write('<BODY '
    +'BGCOLOR="#'+BackColor+'" '
    +'  TEXT="#'+TextColor+'">'
    +'<FONT FACE="'+FontType+'">'
    )
    //-->
    </SCRIPT>
    </HEAD>
    <BODY>
    <FORM NAME="colors" ID="colors" ACTION=""><SELECT NAME="s0" ONCHANGE="if(this.selectedIndex!=0) {BackColor=this.options[this.selectedIndex].value; resetColors()}">
    <OPTION VALUE="choose">BGcolor</OPTION>
    <OPTION VALUE="FFFFFF">White</OPTION>
    <OPTION VALUE="000000">Black</OPTION>
    <OPTION VALUE="CCFFFF">Light blue</OPTION>
    <OPTION VALUE="FFFFCC">Light yellow</OPTION>
    <OPTION VALUE="CCCCCC">Gray</OPTION>
    </SELECT> <SELECT NAME="s1" ONCHANGE="if(this.selectedIndex!=0) {TextColor=this.options[this.selectedIndex].value; resetColors()}">
    <OPTION VALUE="choose">TEXT color</OPTION>
    <OPTION VALUE="000000">Black</OPTION>
    <OPTION VALUE="FFFFFF">White</OPTION>
    <OPTION VALUE="666666">Dark Gray</OPTION>
    <OPTION VALUE="006600">Dark Green</OPTION>
    <OPTION VALUE="0000FF">Blue</OPTION>
    <OPTION VALUE="FFFF00">Yellow</OPTION>
    </SELECT> <SELECT NAME="s2" ONCHANGE="if(this.selectedIndex!=0) {FontType=this.options[this.selectedIndex].value; resetColors()}">
    <OPTION VALUE="choose">Font Type</OPTION>
    <OPTION VALUE="Verdana">Verdana</OPTION>
    <OPTION VALUE="Times New Roman">Times New Roman</OPTION>
    <OPTION VALUE="Arial">Arial</OPTION>
    <OPTION VALUE="Comic Sans MS">Comic Sans MS</OPTION>
    <OPTION VALUE="Helvetica">Helvetica</OPTION>
    <OPTION VALUE="Impact">Impact</OPTION>
    </SELECT></FORM>
    <HR>
END
#=======================================================================================================================
    # Pre-Compiled Regex
#=======================================================================================================================
$bookend_regex = qr/&lsaquo;~&dagger;~&rsaquo; &tau;&epsilon;&lambda;&omicron;&sigmaf; &lsaquo;~&dagger;~&rsaquo;|-&laquo;&raquo;-&laquo;&raquo;-&laquo;&raquo;-/i;
$script_regex = qr/var str='';/i;
$root_regex = qr/C:\\Users\\Admin\\Documents\\Ebooks\\/i;
$css1_regex = qr/<STYLE TYPE="text\/css">/i;
$css2_regex = qr/h1, h2 {\s*text-align: center(?:;*|\s*)}/i;
$postbody_regex = qr/<\/SELECT><\/FORM>|<H1>/i;
$oddquote_regex = qr/^(\<P[^\>]*?\>)((?:[^"\n\r\f\e]*)(?:"[^"\n\r\f\e]*"[^"\n\r\f\e]*)*?)(?<! )" (.*?<\/P>)$/im;
$evenquote_regex = qr/^(\<P[^\>]*?\>)((?:[^"\n\r\f\e]*?"[^"\n\r\f\e]*?)(?:(?:"[^"\n\r\f\e]*?"[^"\n\r\f\e]*?)?)*) "(.*?<\/P>)$/im;
$compound1_regex = qr/
\b(
(?<c1>anti)\x20(?<c2>dotes?)
|(?<c1>back)\x20(?<c2>ground)
|(?<c1>boy|girl)\x20(?<c2>friends?)
|(?<c1>class)\x20(?<c2>mates?)
|(?<c1>else)\x20(?<c2>where)
|(?<c1>eaves)\x20(?<c2>dropping)
|(?<c1>for|when)\x20(?<c2>ever)
|(?<c1>good)\x20(?<c2>byes?)
|(?<c1>her|him|my|your)\x20(?<c2>self)
|(?<c1>home)\x20(?<c2>made)
|(?<c1>house)\x20(?<c2>hold)
|(?<c1>make)\x20(?<c2>shift)
|(?<c1>note|text)\x20(?<c2>books?)
|(?<c1>other)\x20(?<c2>wise)
|(?<c1>out|in)\x20(?<c2>sides?)
|(?<c1>over)\x20(?<c2>slept)
|(?<c1>pass)\x20(?<c2>words?|ports?)
|(?<c1>some)\x20(?<c2>ones?)
|(?<c1>time)(?:\x20|-)(?<c2>lines?)
|(?<c1>under)\x20(?<c2>age)
|(?<c1>wall)\x20(?<c2>papers?)
|(?<c1>wed)\x20(?<c2>lock)
|(?<c1>week)\x20(?<c2>ends?)
|(?<c1>week)\x20(?<c2>days?)
|(?<c1>with)\x20(?<c2>out)
|(?<c1>your|them)\x20(?<c2>selves)
)\b(?!-)/ix; #regular concatination
$compound2_regex = qr/
\b(
(?!Armchairs?)(?:(?<c1>(?:A|a)rm)\x20?(?<c2>(?:C|c)hairs?))
|(?!(?:Bath|Bed|Court|Class|Wash)rooms?)(?:(?<c1>(?:B|b)ath|(?:B|b)ed|(?:C|c)ourt|(?:C|c)lass|(?:W|w)ash)\x20?(?<c2>(?:R|r)ooms?))
|(?!Bodyguards?)(?:(?<c1>(?:B|b)ody)\x20?(?<c2>(?:G|g)uards?))
|(?!Book(?:cases?|shops?|stores?))(?:(?<c1>(?:B|b)ook)\x20?(?<c2>(?:C|c)ases?|(?:S|s)hops?|(?:S|s)tores?))
|(?!Butterbeers?)(?:(?<c1>(?:B|b)utter)\x20?(?<c2>(?:B|b)eers?))
|(?!Earrings?)(?:(?<c1>(?:E|e)ar)\x20?(?<c2>(?:R|r)ings?))
|(?!Grave(?:yards?|stones?))(?:(?<c1>(?:G|g)rave)\x20(?<c2>(?:Y|y)ards?|(?:S|s)tones?))
|(?!Grand(?:mother|father|son|daughter|parents?|dads?|das?|mums?|mas?|moms?))(?:(?<c1>(?:G|g)rand)(?:\x20|-)
(?<c2>(?:M|m)other|(?:F|f)ather|(?:S|s)on|(?:D|d)aughter|(?:P|p)arents?|(?:D|d)ads?|(?:D|d)as?|(?:M|m)ums?|(?:M|m)as?|(?:M|m)oms?))
|(?!Head(?:masters|mistress(?:es)?))(?:(?<c1>(?:H|h)ead)\x20?(?<c2>(?:M|m)asters?|(?:M|m)istress(?:es)?))
|(?!Mudbloods?)(?:(?<c1>(?:M|m)ud)(?:\x20|-)?(?<c2>(?:B|b)loods?))
|(?!Muggleborns?)(?:(?<c1>(?:M|m)uggle)\x20?(?<c2>(?:B|b)orns?))
|(?!Mundaneborns?)(?:(?<c1>(?:M|m)undane)\x20?(?<c2>(?:B|b)orns?))
|(?!Newspapers?)(?:(?<c1>(?:N|n)ews)\x20?(?<c2>(?:P|p)apers?))
|(?!Portkeys?)(?:(?<c1>(?:P|p)ort)\x20?(?<c2>(?:K|k)eys?))
|(?!Stair(?:ways?|cases?))(?:(?<c1>(?:S|s)tair)\x20?(?<c2>(?:W|w)ays?|(?:C|c)ases?))
)\b(?!-)/x;  #\u$1\l$2
$Nouns_regex = qr/
\b(?<!;)(
aurors?|(?:dis)?apparat(?:ing|ed?)|apparition|asphodel|aunt(?:'?s)?|april|august|autumn|astronomy|arthur|albus|animagus|akatsuki|axes?|acromantulas?|air|ashwinders?|animagis?
|arrows?|azkaban|arithmancy|arteries?|aconite|animals?|angels?|asteroids?
|brooms?|bloods?|boggarts?|basilisks?|brother(?:'?s)?|butterbeers?|byakugan|bunshins?|birds?|bones?|bunshins?|banshees?|black|brown|blue|badgers?|bats|bows?|bronze|beers?
|beetle|(?<=(?:A|a)\x20)bears?|(?<=(?:T|t)he\x20)bears?|(?<=(?:A|a)\x20)bats?|(?<=(?:T|t)he\x20)bats?|birthday|beaks?|boomslang|bicorn|bod(?:y|ies)|barriers?|balloons?|bombs?
|bullets?
|crucios?|cruciatus|castles?|cousin|centaurs?|chess|cat|charm(?:s|ed)?|curtains?|cloaks?|curses|contraceptives?|class(?:es)?|chairs?|cottages?|champions?|chocolate|chants?|cups?
|clothes|cannons?|coats?|coffee'?s?|chakras?|contracts?|canines?|chidori|clones?|claws?|countr(?:y|ies)|cats?|copper|chimera'?s?|cobras?|camel|curses?|coyotes?|creatures?
|corn|carriages?|(?:cup)?cakes?|cubs?|chaos|cauldrons?|cupboards?|chalkboards?|casinos?|cit(?:y|ies)|captains?|ch&\#363\;nin
|dogs?|doctors?|dragon(?:et|s)?|diadem|diary(?:'?s)?|diaries|divination|dungeons?|december|departments?|dementors?|dumbledore|dean|doujutsus?|dango|demons?|death|dark
|daughters?|deer|dwarfs?|doe|dad(?:dy)?s?|dolphins?|demiguises?|donkeys?|(?<!\&)daggers?|diamond|destiny|deathday|dirt|dandelion|dryads?|daimy&\#333\;|doton
|enchantments?|expelliarmus|emeralds?|earth|east|(?<!(?:W|w)ide-)eye(?:s?|brows?)?|eagles?|ears?
|fathers?|forks?|february|feathers?|frogs?|fred|fox(?:es)?|fires?|forests?|ferrets?|fish(?:'|e|ie)s?|fates?|flames?|falcons?|foods?|fur|fluxweed|flames?|fir|fog|familiars|flesh
|f&#363\;injutsu|fianc&eacute\;e|futon
|gold|giants|gargoyles?|gobstones?|gnomes?|goblins?|goblets?|(?:god|grand)(?:s|ess(?:'s|es)?|parents?|sons?|daughters?|mothers?|mas?|pas?|das?|fathers?)?|graveyard(?:'?s)?
|grim|governments?|governors?|ginny|ginevra|george|godric|griphook|galleons?|genins?|genjutsu|gates?|ghosts?|green|griffins?|goats?|glamours?|grays?|grass|gas|golems?
|galax(?:y|ies)|grenades?|generators?|griffindors?
|howlers?|harry|husbands?|hermione|hex(?:es)?|head(?:masters?|mistress(?:es)?)|heartstrings?|humans?|horses?|hotels?|horcrux(?:es)?|healers?|heirs?|hagrids?|hedwig
|hippogriffs?|hydra|hokage|hinatas?|henges?|hammers?|herbology|hearts?|house(?:es)?|hares?|hawks?|hairs?|horns?|heat|hy&\#363\;ga|heavens?|hufflepuffs?
|immobilis|iwa(?:gakure)?|iron|insects?
|jinx(?:es)?|january|june|july|jutsus?|jaws?|jeans?|jerseys?|juice|jets?|jutsu|jinch&\#363\;riki|j&\#333\;nin|j&\#363\;ken
|king(?:'?s)?|knight|kitchen(?:'?s)?|kni(?:fes?|ves)|kneazles?|kunais?|katanas?|kinjutsu|kenjutsu|kunoichis?|kages?|kits?|kodachi|kitsunes?|kami|konoha(?:gakure)?|kaa|kazekage
|kumo(?:gakure)?|kiri(?:gakure)?|kakashis?|kibas?|kikai|kanji|kittens?|ky&\#363\;bi|katon
|imperios?|imperius|inferi|islands?|infirmary|imouto|inos?|inoichi|ice|ions?|iris
|lockets?|library(?:'?s)?|lion(?:ess)?s?|life|legilimen(?:cy|s)|luna|lily|lightning|leaf|lady|lord|lethifolds?|lycanthropy|lockers?|lakes?|librarians?|laxatives?|light|lungs?
|lacewing|labyrinths?|leprechauns?
|maps?|masters?|mudbloods?|minister(?:'?s)?|mistress(?:es)?|mundaneborn|muggle(?:born)?s?|ministry(?:'?s)?|magics?|mothers?|m(?:u|o)m(?:mys?)?|masks?|minerva|mcGonagall
|marauders?|molly|malfoy|m(?:rs?|s)|mizukage|mercenarys?|mages?|mares?|manticores?|madam|mutts?|milk|mer(?:people|maids|person|man|men)s?|minotaur|mistletoe|mouse
|mice|metamorph(?:s|mag(?:i|us))?|mountains?|monkshood|mumm(?:y|ies)|mist|monkeys?|mud|metals?|ministers?|moon
|neighbors?|nurses?|newspapers?|november|neville|ninjutsu|ninjas?|nodachis?|narutos?|nii|nee|nargles?|nephews?|nieces?|nymphs?|naiad(?:s|es)?|nundu|nuclear
|nanites?|naquad(ri)?ah
|owl(?:ery|s)?|occlumen(?:s|cy)|obliviated?|october|oaths?|orphanages?|otters?|otouto|obliviations?|organs?|oranges?
|puppy|parsel(?:tongue|mouth)s?|portkeyed|prophe(?:t|cys?|cies)|professors?|pensieves?|potion(?:s|ed)?|polyjuice|phoenix(?:e?s)?|patronus|portraits?|prefects?
|prince(?:'?s|ss|sses)?|parchment|portkey(?:s|ing)?|pendants?|parents?|poisons?|panthers?|patronus(?:es)?|patroni|prison|parvati|padma|peacocks?|petunia|pots?
|patronum|potters?|pneumonia|platinum|pon(?:ys?|ies)|poppy|puppet(eer)?s?|pepper(?:mints?)?|part(?:y|ies)|p(?:a|y)jamas?|pups?|pixies|purple|pans?|pumpkins?
|pink|poltergeist|pandas?|plants?|police|planets?|presidents?|pineapples?
|quills?|queen(?:'?s)?|quidditch|quaffles?
|rats?|runes?|rivers?|refrigerator|rituals?|robes?|ron|remus|richard|rasengans?|ramen|rabbit|raikage|ravens?|red|runespoors?|restoratives?|(?<!breathing\x20)rooms?
|(?<=(?:T|t)he\x20)rings?|ruby|reptiles?|rice|ravenclaws?|ryous?
|squibs?|seers?|snakes?|staffs?|spoons?|students?|school(?:'?s)?|stags?|shields?|stunners?|sister(?:'?s)?|statues?|september|summers?|swords?|silver|souls?|snape
|shinobi|sirius|seamus|shurikens?|sharingans?|succubus|shunshin(?:ed)?|sandaime|shodaime|slugs?|senseis?|suna|sannins?|sakuras?|sasukes?|shinos?|shizune|shinobis?
|shadows?|sands?|sushi|snow|samurai|steel|sharks?|snowy|south|storms?|sons?|sugar|salt|sphinx|sapphires?|serum|serpent|stones?|stairs?|skins?|snouts?|sages?
|stargates?|stars?|systems?|solar|seas?|slytherins?|suiton
|thestrals?|transfigurations?|tables?|tongue|telly|temples?|towers?|trolls?|teacher(?:'?s)?|tarantallegra|tigers?|trace(?:ing)?|tracking|tea|tonks|telepaths?|toilets?|taijutsu|toads?
|tsuchikage|tsunade|tenketsu|talons?|thunder|turtles?|titanium|twins?|teeth|trouts?|trees?|towns?|tokra
|unicorns?|uncles?|university
|veelas?|vaults?|veritaserum|vampires?|vernon|villager?s?|venoms?
|weasels?|weddings?|wars?|whiske?y|wi(?:fe|ves)|windows?|(?:were)?(?:wolf|wolves)|wormwood|wizards?|witch(?:es)?|wands?|wandless|world(?:'?s)?|waters?|west|wards?
|winter|warriors?|weasley|wormtail|wine|wraiths?|whites?|warlocks?|wolfsbane|walls?
|yondaime|youkai|yellow
|zanbatou
)\b/x;
$spells_jutsu_regex = qr/
\b(
adoption|ancient|apparation|alarm|animation|aging
|banishing|binding|blood|bonding|black|bludgeoning|blinding|bubblehead|blocking|blasting|burning|bottomless
|caterwauling|clean(?:ing)|comfort|communication|compulsion|conjuring|cooling|cushioning|cutting|confundus|cheering|clothes|counter|cauterising|concealing
|concealment|cosmetic|contraception|concussion|colou?r(?:ing)?|cramp|calming|combat|camouflage|cobra|concealment|cloaking|chaotic
|dark|depilatory|detection|disarming|disillusion(?:ment)?|death|drying|defense?(?:ive)?|doton|diagnostic
|expansion|enlarging|endurance|explosive
|flight|floating|(?:flame(?:-|\x20))freezing|fire|flame|fidelius|fertility|family|fuu?ton
|glamour|gauging
|healing|heating|hiding|hangover|hover|heritage|headache|holding|household|hyouton
|imperturbable|invisibility|impotence|imperius|illusion|intention|incarcerous
|killing|katon
|levitat(?:e|ing|ion)|(?:un)?locking|lumos|light|love|lucky?|lust|library|locator
|memory|muffling|mind|merger|muffliato|monitoring|mokuton|multitasking|marriage
|Notice-Me-Not|numbing
|offense?(?:ive)?
|privacy|protect(?:ion|ive)|pain|patronus|poison|packing|protean|petrifying|pleasure|parsel|prank
|recording|repelling|restorative|revealing|reductor?|refreshing|replenishment|reducing|raiton|(?:pain(?:-|\x20))?relieving
|scanning|shield(?:ing)?|silenc(?:e|ing)|sleep(?:ing)?|sonorous|stasis|stinging|stunning|swelling|severing|summoning|soul|sticking|security|stupefy|shrink(?:ing)?
|stamina|sobering|simulation
|suiton|safety|secrecy|suppression
|tickle|tickling|tracking|translation|truth|transport
|unbreakable|unforgivable|under\x20age
|veritas
|ward(?:ing)?|warming|white|wandless
)\x20((?:charm(?:ed|s)?|hex(?:es)?|curses?|drought|draughts?|potions?|spells?|wards?|rituals?|runes|magics?|serum|jutsus?|jinx(?:e?s)?))\b/ix;

$ccodes1 = qr/&Atilde\;&copy\;/;
$ccodes2 = qr/&agrave\;&permil\;/;
$ccodes3 = qr/&acirc\;&euro\;&brvbar\;/;
$ccodes4 = qr/&acirc\;&euro\;((?:\<(?:\/?[^\>]+)\>)*(?:\x20)*)"/;
$ccodes5 = qr/&Atilde\;&sect\;/;
$ccodes6 = qr/&Atilde\;&macr\;/;
$ccodes7 = qr/&Aring\;&laquo\;/;
$ccodes8 = qr/&Atilde\;/;
$ccodes9 = qr/&Aring\;/;
$ccodes10 = qr/&agrave\;&micro\;/;
$ccodes11 = qr/&agrave\;&ordf\;/;
$ccodes12 = qr/&agrave\;&reg\;/;
$ccodes13 = qr/&agrave\;&euro\;/;
$ccodes14 = qr/&Auml\;&Dagger\;/;
$ccodes15 = qr/&Acirc\;&frac(\d\d)\;/;
$ccodes16 = qr/&Auml\;&shy\;/;
$ccodes17 = qr/&Auml\;"/;
$ccodes18 = qr/&acirc\;&euro\;&trade\;/;
$ccodes19 = qr/&agrave\;&uml\;/;
$ccodes20 = qr/&acirc\;"&cent\;/;
$ccodes21 = qr/&Acirc\;&pound\;/;
$ccodes22 = qr/&Aring\;&OElig\;/;
$ccodes23 = qr/&acirc\;&amp\;\#8364(?:"\;|\;")/;
$ccodes24 = qr/&\#333\;&OElig\;/;
$ccodes25 = qr/&agrave\;&cent\;/;
$ccodes26 = qr/(?:\%C3\%BE|\&agrave\;\&frac34\;)/;
$ccodes27 = qr/(?:\%C3\%AD|\&agrave\;\&shy\;)/;

$symb1 = qr/\b-(Kun|Chan|Sama|Sensei|San|Nii|Nee)/;
$a1 = qr/\bapp?aration|app?eration\b/i;
$a6 = qr/\bapp?erated|app?irated\b/i;
$a2 = qr/\b(?!Apparition Point)(?:(?:A|a)ppar(?:a|i)tion (?:P|p)oint)/;
$a3 = qr/\b(?!anti-\w+|anti\x20dotes?)(?<!<P>)(?<!<P>")(?<!<P>\()(?:(?:anti|Anti)(?:\x20|-)+(\w+))/;
$a4 = qr/\b(?!ANBU)(?:(A|a)(?:N|n)(?:B|b)(?:U|u))\b/;
$a5 = qr/\b(?!Avada Kedavra)(?:(?:A|a)vada (?:K|k)adavera|(?:A|a)vada (K|k)edavra)/; #kadavera
$b1 = qr/\b(?!Bat Bogey)(?:(?:B|b)at (?:B|b)ogey)/;
$b2 = qr/\b(?!Blood (?:Protections?|Traitors?))(?:(?:B|b)lood ((?:P|p)rotections?|(?:T|t)raitors?))\b/;
$b3 = qr/\b(?!(?:Pure|Half)-(?:bloods?|blooded|breeds?))((?:P|p)ure|(?:H|h)alf)(?:\x20|-)?((?:B|b)lood(?:s|ed)?|(?:B|b)reeds?)\b/;
$b4 = qr/\b(?!Boy-Who-(?:Lived|Conquered|Vanquished))(?:(?:B|b)oy(?:\x20|-)+(?:W|w)ho(?:\x20|-)+((?:L|l)ived|(?:C|c)onquered|(?:V|v)anquished))\b/;
$b5 = qr/\bbijuu?/i;
$b6 = qr/\b(?!Bunshin)(?:(?:B|b)ushin|bunshin)/;
$c1 = qr/\bcliche/i;
$c2 = qr/\b(?!Care of Magical Creature)(?:(?:C|c)are (?:O|o)f (?:M|m)agical (?:C|c)reature)/;
$c3 = qr/\b(?!Curse Breaker)(?:(?:C|c)urse (?:B|b)reaker)/;
$c4 = qr/\b(?!Christmas Day)(?:(?:C|c)hristmas (?:D|d)ay)/;
$c5 = qr/\bcharka/i;
$c6 = qr/\bchuunin|chunin|chunnin/i;
$c7 = qr/\b(?!Coup-de-gr\&acirc\;ce)(?:(?:C|c)oup(?:-|\x20)(?:D|d)e(?:-|\x20)(G|g)r(?:\&acirc\;|a)ce)\b/;
$d1 = qr/\b(?!Department of Mysteries)(?:(?:D|d)epartment(?:-|\x20)(?:O|o)f(?:-|\x20)(?:M|m)ysteries)/;
$d2 = qr/(?!Dark (?:Marks?|Arts?|Creatures?|Lords?|Wizards?|Witch(?:es)?))(?:\b(?:D|d)ark ((?:M|m)arks?|(?:A|a)rts?|(?:C|c)reatures?|(?:L|l)ords?|(?:W|w)izards?|(?:W|w)itch(?:es)?)\b)/;
$d3 = qr/(?!Death (?:Munchers?|Nibblers?|Eaters?|Wankers?))(?:\b(?:D|d)eath ?((?:M|m)unchers?|(?:N|n)ibblers?|(?:E|e)aters?|(?:W|w)ankers?)\b)/;
$d4 = qr/\b(?!Defense Against the Dark Arts)(?:(?:D|d)efense (?:A|a)gainst (?:T|t)he (?:D|d)ark (?:A|a)rts)/;
$d5 = qr/\b(?!Dreamless (?:Sleep|Sleeping) Potion)(?:(?:D|d)reamless ((?:S|s)leep(?:ing)?) (?:P|p)otion)/;
$d6 = qr/\bDanzo\b/i;
$d7 = qr/\b(?!Disapparition)(?:(?:D|d)iss?app?aration|(?:D|d)iss?app?eration|(?:D|d)issapparition)\b/;
$d8 = qr/\b(?!Disapparated)(?:(?:D|d)iss?app?erated|(?:D|d)iss?app?irated|(?:D|d)issapparated)\b/;
$d9 = qr/\b(?!Dressing Gown)(?:(?:D|d)ressing (?:G|g)own)/;
$d10 = qr/\b(?:D|d)aimyou?\b/;
$e1 = qr/\b(?!Extendable Ear)(?:(?:E|e)xtend(?:a|i)ble (?:E|e)ar)/;
$e2 = qr/\b(?!(?:House|High|Wood)-(?:elves|elf))(?:((?:H|h)ouse|(?:H|h)igh|(?:W|w)ood)(?:\x20|-)?((?:E|e)lves|(?:E|e)lf))/;
$f1 = qr/\b(?!Firewhiskey)(?:(?:F|f)ire\x20?(?:W|whiskey))\b/;
$f2 = qr/\b(?!Fidelius)(?:(?:F|f)idelius|(?:F|f)idelus)\b/;
$f3 = qr/\bfuinjutsu/i;
$f4 = qr/\bfiancee?/i;
$g1 = qr/\b(?!Great Hall)(?:(?:G|g)reat (?:H|h)all)/;
$g2 = qr/\b(?!Genin)(?:(?:G|g)ennin)/;
$h1 = qr/(?!He-Who-Must-Not-Be-Named)(?:(?:H|h)e(?:\x20|-)+(?:W|w)ho(?:\x20|-)+(?:M|m)ust(?:\x20|-)+(?:N|n)ot(?:\x20|-)+(?:B|b)e(?:\x20|-)+(?:N|n)amed)/;
$h2 = qr/\b(?!Half Giant)(?:(?:H|h)alf(?:\x20|-)?(G|g)iant)/;
$h3 = qr/\b(?!Heads? (?:Boy|Girl|Table|Office))(?:((?:H|h)eads?)\x20?((?:B|b)oy|(?:G|g)irl|(?:T|t)able|(?:O|o)ffice))/;
$h4 = qr/\b(?!Head of House)(?:(?:H|h)ead (?:O|o)f (H|h)ouse)/;
$h5 = qr/\b(?!Hit (?:Wizards?|Witch(?:es)?))(?:(?:H|h)it ((?:W|w)izards?|(?:W|w)itch(?:es)?))\b/;
$h6 = qr/\b(?!Hogwarts Express)(?:(?:H|h)ogwarts (?:E|e)xpress)/;
$h7 = qr/\b(?!Hospital Wing)(?:(?:H|h)ospital (?:W|w)ing)/;
$h8 = qr/\b(?!House (?:Points?|Cup))(?:(?:H|h)ouse ((?:P|p)oints?|(C|c)up))/;
$h9 = qr/\bhyuuga|hyuga/i;
$h10 = qr/\b(?!Hitai-ate)(?:(?:H|h)itai-(?:A|a)te|(?:H|h)etai-(?:I|i)te)/;
$h11 = qr/\b(?!Hunter Nin)(?:(?:H|h)unter(?:\x20|-)(?:N|n)in)/;
$i1 = qr/\b(?!Invisibility Cloak)(?:(?:I|i)nvisibility (?:C|c)loak)/;
$i2 = qr/\b(?!Ice Cream)(?:(?:I|i)ce (?:C|c)ream)/;
$i3 = qr/\b\b(?!Imperius (?:Curse|Potion))(?:(?:(?:I|i)mperius|(?:I|i)mperious) ((?:C|c)urse|(?:P|p)otion))/;
$j1 = qr/\b(?!Jutsu)(?:(?:J|j)ustu)/;
$j2 = qr/\bjinn?chuu?rr?ikk?i|Jinchuirki/i;
$j3 = qr/\bjounin|jonin/i;
$j4 = qr/\bjyuuken|juuken|jyuken/i;
$j5 = qr/\b(?!)(Jr.|Sr.) ([A-Z])/i;
$j6 = qr/\b(?!Jelly-Legs?)(?:(?:J|j)elly(?:\x20|-)(?:L|l)egs?)/;
$k1 = qr/\b(?!Know-It-All)(?:(?:K|k)now(?:\x20|-)?(?:I|i)t(?:\x20|-)?(?:A|a)ll)/;
$k2 = qr/\b(?!Kekkei Genkai)(?:(?:K|k)ekkei (?:G|g)enkai|(?:K|k)ekkai (?:G|g)enkai)/;
$k3 = qr/\b(?!Kneazle)(?:kneazle|(?:K|k)neezle)/;
$k4 = qr/\bkyuubi|kyubi/i;
$l1 = qr/\b((?:god|grand)?(?:sons?|daughters?|fathers?|mothers|sisters?|brothers?))(?:\x20|-)?in(?:\x20|-)?law/i;
$l2 = qr/\b(?!Lemon Drop)(?:(?:L|l)emon (?:D|d)rop)/;
$l3 = qr/\b(?:Leaky Cauldron)(?:(?:L|l)eaky (?:C|c)auldron)/;
$l4 = qr/\b(?:Legilimency)(?:(?:L|l)egill?im(?:a|e)ncy)/;
$m1 = qr/\b(?!Muggleborn)(?:muggleborn|(?:M|m)uggle-(?:B|b)orn)/;

$m2 = qr/\b(?!Martial Art)(?:(?:M|m)artial (?:A|a)rt)/;
$m3 = qr/\b(?!(?:Magical|Wizarding)\x20(?:Creature|World|Core|Warrior|Government|Blood|Oath))
(?:((?:M|m)agical|(?:W|w)izarding)\x20((?:C|c)reature|(?:W|w)orld|(?:C|c)ore|(?:W|w)arrior|(?:G|g)overnment|(?:B|b)lood|(?:O|o)ath))/x;
$m4 = qr/\b(?!Mundaneborn)(?:mundaneborn|(?:M|m)undane-(?:B|b)orn)/;
$n1 = qr/\bNotice(?:\x20|-)Me(?:\x20|-)Not/i;
$n2 = qr/\bN\.\x20?E\.\x20?W\.\x20?T\.?(?:\x20?(S))?\b/;
$n3 = qr/\b(N|n)aive\b/;
$o1 = qr/\border of the Phoenix/i;
$o2 = qr/\bocculmency/i;
$o3 = qr/\bO\.\x20?W\.\x20?L\.?(?:\x20?(S))?\b/;
$o4 = qr/\b(O|o)noki\b/;
$p1 = qr/\bportrait hole/i;
$p2 = qr/\bprivet Drive/i;
$p3 = qr/\bquidditch pitch/i;
$p4 = qr/\bpumpkin juice/i;
$p5 = qr/\bPetrificus totalus/i;
$p6 = qr/prophesy/i;
$p7 = qr/pomphrey|Pompfrey/i;
$p8 = qr/parceltongue|parsletongue|\bparcel tongue\b/i;
$p9 = qr/(?!Parsel Magic)(?:(?:P|p)ar(?:C|c)el\x20?(?:M|m)agic)/;
$p10 = qr/Proffessor/i;
$p11 = qr/\bpatronous|patranous/i;
$p12 = qr/\bpractis(ing|ed?)/i;
$p13 = qr/\bparslemouth/i;
$p14 = qr/\b(?!Pepper-?Up)(?:(?:P|p)epper(?:\x20|-)(?:U|u)p)\b/;
$p15 = qr/\b(?!Prank War)(?:(?:P|p)rank\x20?(?:W|w)ar)/;
$r1 = qr/\b(common|living|dining|portrait|sitting|waiting|powder|throne) room/i;
$r2 = qr/\broom of requirement/i;
$r3 = qr/\b(promise|engagement|wedding|diamond|portkey|pinky|toe|nipple|learning|reading|family|signet|gold(?:en)?|silver|metal|trinium) ring/i;
$r4 = qr/\b(his|her|the|their|my|your|our|those|set of|pair of|this|that) ring/;
$r5 = qr/\brookie (nine|9)|Rookie nine|rookie Nine/;
$s1 = qr/\bsecret keeper/i;
$s2 = qr/\bshrieking shack/i;
$s3 = qr/\bsorting hat/i;
$s4 = qr/\bsoul(?:\x20|-)?mate/i;
$s5 = qr/\bspell crafting/i;
$s6 = qr/\b(philosopher'?s?|sorcerer'?s?) stone\b/i;
$s7 = qr/\bshushin/i;
$s8 = qr/\b(?!Sexy-no-Jutsu)(?:sexy(?:\x20|-)?no(?:\x20|-)?jutsu)/i;
$s9 = qr/\b(summoning|storage|toad|slug|canine|fox) (scroll|contract)/i;
$s10 = qr/\b(?!Summon Boss)(?:(?:S|s)ummon (?:B|b)oss)/i;
$s11 = qr/\bSamaheda/i;
$s12 = qr/\b(?!Skele-Grow)(?:(?:S|s)kele-(?:G|g)row)/;
$t1 = qr/\btime turner/i;
$t2 = qr/\b(elm|apple|cherry|sakura|elder|oak|redwood|elm|christmas|evergreen|chestnut|cedar) tree/i;
$t3 = qr/\b((?:(?:P|p)hoenix|(?:H|h)uman)\x20)(tears?)\b/;
$u1 = qr/\bunbreakable vow/i;
$w1 = qr/(?!Whiskey)(?:\b(?:W|w)hiske?y)/;
$y1 = qr/\byoko/i;
$y2 = qr/\b(first|second|third|fourth|fifth|sixth|seventh|new)\x20(year)/i;

$helper1 = qr/
<P\x20CLASS=\"..\">-&laquo;&diams;&laquo;&diams;&raquo;&diams;&raquo;-<\/P>
|<P\x20CLASS=\"a1\">~&laquo;&alefsym;&laquo;&weierp;&lsaquo;&dagger;&rsaquo;&weierp;&raquo;&alefsym;&raquo;~<\/P>
|<P\x20CLASS=\"a1\">~&\#171;&\#8501;&\#171;&\#8472;&\#8249;&\#8224;&\#8250;&\#8472;&\#187;&\#8501;&\#187;~<\/P>
|<HR\x20CLASS=.*?NOSHADE.*?>
|<HR\x20SIZE=.*?\x20NOSHADE.*?>
|<HR\x20.*?>
/ix;

$helper2 = qr/
:link\x20{\x20color:\x20\w+\x20}
|:visited\x20{\x20color:\x20\w+\x20}
|(h1|h2|hr|div)\.c.\x20{text-align:\x20center}
|LinkColor="0000FF"
|VlnkColor="660099"
|str\+='LinkColor="'\+LinkColor\+'"\;'\;
|str\+='VlnkColor="'\+VlnkColor\+'"\;'\;
|\+'\x20\x20LINK="#'\+LinkColor\+'"\x20'
|\+'\x20\x20VLINK="#'\+VlnkColor\+'">'
|<LINK\x20REL="Edit.*?>
/ix;

$bookendhelper = qr/<P CLASS=\"a1\">&lsaquo\;~&dagger\;~&rsaquo\; &tau\;&epsilon\;&lambda\;&omicron\;&sigmaf\; &lsaquo\;~&dagger\;~&rsaquo\;<\/P>/is;
$hrbreakhelper = qr/<P CLASS=\"a1\">~&laquo\; &laquo\;&lsaquo\;&sect\;&rsaquo\;&raquo\; &raquo\;~<\/P>/is;
#=======================================================================================================================
    # Open Directory and read in each file
#=======================================================================================================================
if (defined($ARGV[0]) && $ARGV[0] ne '') { $path = shift(@ARGV); }
else { $path = dirname($0); }

if ($path =~ /\.html?$/i) {
    $dir = dirname($path);
    $f = basename($path);
}
else { $dir = $path; }

$dir =~ s/\//\\/ig;
if ($dir !~ /\\$/i) { $dir = $dir . "\\"; }

chdir("$dir");
#=======================================================================================================================
if ($f ne '') { $htmlfiles[0] = $f; } #ARG1 for specific file.
else {
    opendir(DIR, $dir) || die("Cannot open directory");
    @htmlfiles = grep /\.html?$/i, readdir(DIR);
    closedir(DIR);
}

#setup variables for relative icon link based on root directory
$tempdir1 = $dir;
if ($tempdir1 =~ /$root_regex/i) { $tempdir1 =~ s/$root_regex/\\/ig; }
$link = '';
while ($tempdir1 =~ /\\[^\\]*?\\/) {
    $link = $link . "..\/";
    $tempdir1 =~ s/\\.*?\\/\\/;
}
$link2 = "\<LINK REL='shortcut icon' TYPE='image/x-icon' HREF=\'" . $link . $icon_name . "\' \/>";

foreach $f (@htmlfiles) {
    if (($f =~ /\.HTML?$/)&&($extensionHTML eq 'false')) { $extensionHTML = 'true'; }

    #Add or modify favicon link
    open (IN, "<$dir$f") or die "Can't open $dir$f: $!\n";
    local $/;
    $lines = <IN>;
    close IN;
    $_ = $lines;
    
    #Substitutions
    s/\<link rel=\'shortcut icon\'[^>]*>\n//igs;
    s/<HEAD>/<HEAD>\n\n$link2/igs;
    
    if ($_ ne $lines) {
        open (OUT, ">$dir$f") or die "Can't open $dir$f: $!\n";
        print OUT "$_";
        close OUT;
    }
}

$ftotal = scalar(@htmlfiles);
if ($ftotal == 0) {
    print "No Files found";
    sleep(2);
    exit(1);
}

system("rename", "*.HTML", "*.html") if ($extensionHTML eq 'true');
foreach $f (@htmlfiles) {
    $bookendcheck = 'false';
    $scriptcheck = 'false';
    $csscheck1 = 'false';
    $csscheck2 = 'false';
    $postbody = 'false';
    
    chomp($f);
    $fcount++;
    
    #generate $f_2
    $f_2 = $f;
    if ($f =~ /\&|\x20\x20+/) {
        $_ = $f;
        s/\x20\x20+/\x20/ig;
        s/\&/&amp;/ig;
        $f_2 = $_;
    }
    print "\nProcessing ($fcount\/$ftotal): $f\n\tFirst Tidy: ";
    system("C:/Program Files/Tidy/tidy", "-o", "$dir$f", "-config", "C:/Program Files/Tidy/config.txt", "$dir$f");
    system("C:/Program Files/Tidy/tidy", "-o", "$dir$f", "-config", "C:/Program Files/Tidy/config.txt", "$dir$f"); #Run Twice for proper initial clean
    
    #=======================================================================================================================
        # First loop. Handles file contents as a whole rather then line by line. Regex need to take this into account since newline amongst others can be used.
        # This code is blocked so that $/ is returned to its original value after usage.
    #=======================================================================================================================
    START:
    $loop++;
    print "Complete\n\tCleanup [$loop]: ";
    {
        print "0\%";
        open (IN, "<$dir$f") or die "Can't open $dir$f: $!\n";
        local $/;
        $forig = <IN>;
        close IN;
        $_ = $forig;
        #--------------------------------------------------------------------------------------------------------------------------------------------
            #Checks: Looks for indicators in the ebook that will help with changes
        #--------------------------------------------------------------------------------------------------------------------------------------------
        if ($_ =~ /$bookend_regex/) { $bookendcheck = "true"; }
        if ($_ =~ /$script_regex/) { $scriptcheck = "true"; }
        if ($_ =~ /$css1_regex/) { $csscheck1 = "true"; }
        if ($_ =~ /$css2_regex/) { $csscheck2 = "true"; }
        #--------------------------------------------------------------------------------------------------------------------------------------------
            #Substitutions
        #--------------------------------------------------------------------------------------------------------------------------------------------
        if ($section1 == 1) {
            #-First:- These substitutions should run first so as to help the others.
            s/<\/title>/<\/title>\n\n<STYLE TYPE="text\/css"><\/STYLE>/is if $csscheck1 eq "false";
            s/<STYLE TYPE="text\/css">/<STYLE TYPE="text\/css">$css/is if $csscheck2 eq "false";
            s/<\/head>/$del/is if $scriptcheck eq "false";
            s/<body>/$script/is if $scriptcheck eq "false";
            
            s/$helper1/$hrbreak/igs;
            
            s/<P CLASS=\"..\">Back to index<\/P>/$del/is;    #Substitution made specifically for SIYE fanfiction site.
            s/(?:<P>\s*<\/P>|^\s$)/$del/igs;
            s/(?:(?:\.|\x20)*(?:\.\x20?\.\x20?\,|\.\x20?\.\x20?\.|&hellip;)(?:\.|\x20|,)*)/&hellip;/igs;
            s/^.*DOCTYPE.*XHTML.*$//is;
            s/<P CLASS=\"a1\">-&laquo\;&raquo\;-&laquo\;&raquo\;-&laquo\;&raquo\;-<\/P>/$bookend/is;
            #--------------------------------------------------------------------------------------------------------------------------------------------
            #Character code errors
            s/$ccodes1/&eacute\;/gs;
            s/$ccodes2/&Eacute\;/gs;
            s/$ccodes3/&hellip\;/gs;
            s/$ccodes4/-$1/gs;
            s/$ccodes5/&ccedil\;/gs;
            s/$ccodes6/&iuml\;/gs;
            s/$ccodes7/&#363\;/gs;
            s/$ccodes8/&agrave\;/gs;
            s/$ccodes9/&#333\;/gs;
            s/$ccodes10/&otilde\;/gs;
            s/$ccodes11/&ecirc\;/gs;
            s/$ccodes12/&icirc\;/gs;
            s/$ccodes13/&Agrave\;/gs;
            s/$ccodes14/&#263\;/gs;
            s/$ccodes15/&frac$1\;/gs;
            s/$ccodes16/&#301\;/gs;
            s/$ccodes17/&#275\;/gs;
            s/$ccodes18/'/gs;
            s/$ccodes19/&egrave\;/gs;
            s/$ccodes20/&trade\;/gs;
            s/$ccodes21/&pound\;/gs;
            s/$ccodes22|$ccodes24/&#332\;/gs;
            s/$ccodes23/&hellip\;/gs;
            s/$ccodes25/&acirc\;/gs;
			s/$ccodes26/&thorn\;/gs;
			s/$ccodes27/&iacute\;/gs;
            
            print "\b\b10\%";
            #--------------------------------------------------------------------------------------------------------------------------------------------
            #-One Time Only:- Various one time only Substitutions
            if (($bookendcheck && $scriptcheck) eq "false") {
                s/<br>/<p>/igs if $bookendcheck eq "false";
            }
        }
        #--------------------------------------------------------------------------------------------------------------------------------------------
        m/^(.*\<\/SELECT\>\<\/FORM\>)(.*)$/igs;
        $head = $1;
        $body = $2;
        $_ = $head;
        if ($section2 == 1) {
            #-Script/Formatting:- Substitutions to format ebook to style - HEAD
            s/<title>.*<\/title>/<TITLE>$f_2<\/TITLE>/is;
            s/(?:\.html)+<\/TITLE>/<\/TITLE>/is;
            s/(?:div\...|hr\...) {text-align: center}/$del/is if $bookendcheck eq "false";
            s/\<meta.*?\>/$del/is;
            s/<FORM NAME="colors" ID="colors">/<FORM NAME="colors" ID="colors" ACTION="">/is;
            s/\n\x20body\x20\{\n\x20\x20background-color:\x20\w+\;\n\x20\}//is;   #Remove Backround css
            
            s/BackColor="FFFFFF"/BackColor="000000"\;/is;
            s/TextColor="000000"/TextColor="FFFFFF"/is;
            s/\+'  TEXT="#'\+TextColor\+'" '/\+'  TEXT="#'\+TextColor\+'">'/is;
            #--------------------------------------------------------------------------------------------------------------------------------------------
            #-Cleanup:- Substitutions that remove uneeded and useless code - HEAD/CSS
            s/$helper2/$del/igs; #$del will tell script to simply delete entire line from file.
            s/\/\*\<\!\[CDATA\[\*\///igs;
            s/\/\*\]\]\>\*\///igs;
            s/(^\x20?\n)+<\/STYLE>/<\/STYLE>/igm;
        }
        $head = $_;
        #--------------------------------------------------------------------------------------------------------------------------------------------
        $_ = $body;
        #-Script/Formatting:- Substitutions to format ebook to style - BODY
        if ($section3 == 1) {
            s/<\/body>/$bookend/i if $bookendcheck eq "false";
            
            s/<H1 CLASS="..">/<H1>/igs;
            s/<H2 CLASS="..">/<H2>/igs;
            s/<H2>(?!\s*<EM>)/<H2><EM>/igs;
            s/(?<!<\/em>)<\/H2>/<\/EM><\/H2>/igs;
            s/<HR CLASS=".." SIZE="." WIDTH="\d\d?\d?%">/$hrbreak/igs;
            s/<(?:P|P CLASS="a1")>Summary:/<P CLASS="a1"><STRONG>Summary:<\/STRONG>/igs;
            s/<P><STRONG>Summary:<\/STRONG>/<P CLASS="a1"><STRONG>Summary:<\/STRONG>/igs;
            s/("|')<\/EM>/<\/EM>$1/igs;
            s/<EM>("|')/$1<EM>/igs;
            s/<EM>([\.,;:]) "/$1 "<EM>/igs;
            s/([\.,;A-Za-z])<EM>([A-Za-z])/$1 <EM>$2/igs;
            s/(?:\<P[^\>]*?\>)(?:\<(?:\/?[^\>]+)\>)*(?:[~@#*-=\.O\(\)\<\>0oXx ]|&hellip;)+(?:\<(?:\/?[^\>]+)\>)*<\/P>/$hrbreak/igs;
            s/(\d)(st|nd|rd|th)/$1<SUP>$2<\/SUP>/igs;
            s/(\d) (&frac\d\d;)/$1$2/igs;
            #--------------------------------------------------------------------------------------------------------------------------------------------
            #-Cleanup:- Substitutions that remove uneeded and useless code - BODY
            s/^ $//igs;
            s/<\/?(?:div|a\x20|img).*?>//igs;
            s/<EM>(?:<EM>)+/<EM>/igs;
            s/<STRONG>(?:<STRONG>)+/<STRONG>/igs;
            s/<\/EM><\/EM>(?![".,:;']?<\/P>)/<\/EM>/igs;
            s/(?:<\/EM><EM>|<\/STRONG><STRONG>)//igs;
            s/(?:<\/EM> <EM>|<\/STRONG> <STRONG>)/ /igs;
        }
        #--------------------------------------------------------------------------------------------------------------------------------------------
            #-Errors:- Substitutions to fix common errors resulting from file conversion or common author mistakes
        #General: Regex that may or may not be mistakes, to be fixed by following substitutions, or human check.
        if ($section4 == 1) {
            s/\x20(a|p)\.\x20?m\.\x20?/ \u$1M /igs;  #FIX AM/PM
            s/\ba\.\x20K\.\x20A\.?\b/AKA/igs;  #FIX AKA
            s/\b(?:(?:T|t)\.\x20(?:V|v)\.|tv)/TV/gs;  #Fix TV
            s/\bi\.\x20E\./ie./igs;  #Fix ie.
            s/\?(?:\.|,)/\?/igs; #Example: [What?,] ---> [What?]
            s/\.(" [a-z])/,$1/gs; #Example: [." he said.] ---> [," he said]
            s/,( "[A-Z])/.$1/gs; #Example: [he agreed, "Well then] ---> [he agreed. "Well then] error: When a name is used.
            s/"([,;\.!?])/$1"/igs; #Example: ["Hello",] ---> ["Hello,"] error: [",Hello] ---> [,"Hello] Would need a space.
            s/ ([\.,;!?])([A-Za-z])/$1 $2/is; #Example: [said ,and then] ---> [said, and then]
            s/ " /" /igs; #Example: [<P>Then he said " ] ---> [<P>Then he said "]
            s/([\w.,?!])("[\w.,?!])/$1 $2/igs; #Example: [<P>In his head,"I will] ---> [<P>In his head, "I will]
            s/ ' </ '</igs; #Example: [that read ' <EM>Used Books</EM>'] ---> [that read '<EM>Used Books</EM>']
            s/(&hellip;"?)\x20([a-z])/$1 \u$2/gs; #Example: ["ok..." he said.] ---> ["ok..." He said.]
            s/((?:\w|\))[?.,!])(\w)/$1 $2/igs; #Example: [What?How?] ---> [What? How?]
            print "\b\b\b20\%";
            s/([A-Za-z.,;:?!]")([A-Za-z])/$1 $2/igs;
            s/\b(smiled|answered|asked|requested|nodded|chuckled?|laughed|replied|continued|coughed)\b,?( (?:"|'))((?:\<(?:\/?[^\>]+)\>)*[A-Za-z])/$1.$2\u$3/igs;
            s/([A-Za-z])(<\/EM>' [A-Z])/$1.$2/gs;
            s/(\w)("?<\/P>)/$1.$2/igs;
            s/(?:\.?\x20|<P>)(a|the|say|their)\. "([^"]+\w)"/ $1 '$2'/igs;
            s/\x20(\w+)\.? "([\w'\-]+)"/ $1 '$2'/gs;
            s/\b(\d\d?)' ?(\d\d?)((?: |<[^>]*>)* ?)"/$1&prime;$2&Prime;$3/igs; #Height measurements, feet and inches
            s/\b(\d{1,3}\.)\x20(\d+)(\x20?(?:%|percent))/$1$2$3/igs; #99. 9% becomes 99.9%
            s/\b(\x20\d\.)\x20(\d{1,2})\b/$1$2/isg while (/\b(\x20\d\.)\x20(\d{1,2})\b/s);
            s/\b(\d{1,3}),\x20(\d{3})\b/$1,$2/igs while (/\b(\d{1,3}),\x20(\d{3})\b/s); #2, 000, 000 become 2,000,000
            s/\b(?<![&#])(\d{2,})(\d{3})(?!;)\b/$1,$2/igs while (/\b(?<![&#])(\d{2,})(\d{3})(?!;)\b/s);
            #2000000 become 2,000,000 #excluse 4 digit numbers because number can represent a year
            print "\b\b\b30\%";
        }
        #Specific: Regex that target very specific errors. Still may create mistakes, however less likely.
        if ($section5 == 1) {
            s/(?:$hrbreakhelper\n)+<H3>/<H3>/igs; #Remove HR Break before new chapter heading
            s/<\/H3>(?:\n$hrbreakhelper)+/<\/H3>/igs; #Remove HR Break after new chapter heading
            s/\n(?:$hrbreakhelper\n)+$bookendhelper\n<\/BODY>/$bookend/igs;
            s/$bookendhelper(?:\n$bookendhelper)+\n<\/BODY>/$bookend/igs; #Book End showing multiple times
            s/$hrbreakhelper(?:\n$hrbreakhelper)+/$hrbreak/igs; #HRbreak showing multiple times
            s/\&amp\;fraa/&frac/igs;
            s/9\x20&frac14;/9&frac34;/igs; #Harry Potter Fan Fiction common error.
            s/<P CLASS=\"a1\">-\&\#171\;\&\#9830\;\&\#171\;\&\#9830\;\&\#187\;\&\#9830\;\&\#187\;-<\/P>/$hrbreak/igs;
            s/(\<P[^\>]*?\>)" /$1"/is; #Example: [<P>" Hello] ---> [<P>"Hello];
            s/ ([,\.!\?;:]) /$1 /igs; #Example: [Hello , blah blah] ---> [Hello, blah blah]
            s/(?:,|\.)(?:,|\.)(" [a-z])/,$1/gs; #Example: ["Yes.," he said.] ---> ["Yes," he said.] Makes sure 'he' is lowercase.
            s/([A-Za-z][,\.])(?:((?:\<(?:\/[^\>]+)\>)*?)([A-Za-z]))/$1$2 $3/igs; #Example: [he ran,and ran] ---> [he ran, and ran]
            s/(<\/EM>")([A-Za-z])/$1 $2/igs; #Example: ["<EM>Hello</EM>"he said.] ---> ["<EM>Hello</EM>" he said.]
            s/<\/EM>"<\/STRONG>/<\/EM><\/STRONG>"/igs; #Example: [</EM>"</STRONG>] ---> [</EM></STRONG>"]
            s/<STRONG>"<EM>/"<STRONG><EM>/igs; #Example: [<STRONG>"<EM>] ---> ["<STRONG><EM>]
            s/(\<(?:\/(?!sup>)[^\>]+)\>)([\.,?!:;])/$2$1/igs; #Example: [<EM>Do you understand</EM>?] ---> [<EM>Do you understand?</EM>]
            s/\b(?!(?:Sr\.|Jr\.))(?:(\w+[!?\.](?:\<(?:[^\>]+)\>)*)("?\x20?(?:\<(?:[^\>]+)\>)*\x20?"?)([a-z]))/$1$2\u$3/gs; #Capitlization first word of new sentence. Exceptions: Jr./Sr.
            s/(<P>["\(]?)([a-z])/$1\u$2/gs; #Capitalize first word of sentence.
            s/([a-z])( "(?:\<(?:[^\>]+)\>)*)([A-Z])/$1.$2$3/gs; #Example: [he said "Now then...] ---> [he said. "Now then...]
            s/\." (She|he|they)( \w+)(?:\.|,)/," \l$1$2./gs;
            s/\b(the|a|to|called|of)\.\x20"([^"\n\r]+?)"/$1 '$2'/igs;
            s/([,;\.!?])""/"$1"/igs; #Example: [!""] ---> ["!"]
            s/$oddquote_regex/$1$2 "$3/igm while (/$oddquote_regex/s); #odd
            s/$evenquote_regex/$1$2" $3/igm while (/$evenquote_regex/s); #even
            print "\b\b\b40\%";
        }
        #--------------------------------------------------------------------------------------------------------------------------------------------
        if ($section6 == 1) {
            #Nouns
            s/$Nouns_regex/\u$1/xgs;
            #Harry Potter spells/magic
            s/$spells_jutsu_regex/\u$1 \u$2/xigs;
            print "\b\b\b50\%";
            #Compound Words:
            s/$compound1_regex/$+{c1}$+{c2}/xigs;
            #\u$1\l$2
            s/$compound2_regex/\u$+{c1}\l$+{c2}/xgs;
            #Spelling Mistakes/Convention/Other
            #~
            s/$symb1/\-\l$1/gs;
            #A
            s/$a1/Apparition/igs;
            s/$a6/Apparated/igs;
            s/$a2/Apparition Point/gs;
            s/$a3/anti-$1/gs;
            s/$a4/ANBU/gs;
            s/$a5/Avada Kedavra/gs;
            #B
            s/$b1/Bat Bogey/gs;
            s/$b2/Blood \u$1/gs;
            s/$b3/\u$1-\l$2/gs;
            s/$b4/Boy-Who-\u$1/gs;
            s/$b5/bij&#363\;/igs;
            s/$b6/Bunshin/gs;
            #C
            print "\b\b\b60\%";
            s/$c1/clich&eacute;/igs;
            s/$c2/Care of Magical Creature/gs;
            s/$c3/Curse Breaker/gs;
            s/$c4/Christmas Day/gs;
            s/$c5/Chakra/igs;
            s/$c6/Ch&#363\;nin/igs;
            s/$c7/Coup-de-gr&acirc;ce/gs;
            #D
            s/$d1/Department of Mysteries/gs;
            s/$d2/Dark \u$1/gs;
            s/$d3/Death \u$1/gs;
            s/$d4/Defense Against the Dark Arts/gs;
            s/$d5/Dreamless \u$1 Potion/gs;
            s/$d6/Danz&#333;/ig; #Naruto Character
            s/$d7/Disapparition/gs;
            s/$d8/Disapparated/gs;
            s/$d9/Dressing Gown/gs;
            s/$d10/Daimy&#333;/gs;
            #E
            s/$e1/Extendable Ear/gs;
            s/$e2/\u$1-\l$2/gs;
            #F
            s/$f1/Firewhiskey/gs;
            s/$f2/Fidelius/gs;
            s/$f3/F&#363\;injutsu/igs;
            s/$f4/Fianc&eacute\;e/igs;
            #G
            s/$g1/Great Hall/gs;
            s/$g2/Genin/gs;
            #H
            s/$h1/He-Who-Must-Not-Be-Named/gs;
            s/$h2/Half-Giant/gs;
            s/$h3/\u$1 \u$2/gs;
            s/$h4/Head of House/gs;
            s/$h5/Hit \u$1/gs;
            s/$h6/Hogwarts Express/gs;
            s/$h7/Hospital Wing/gs;
            s/$h8/House \u$1/gs;
            s/$h9/Hy&#363\;ga/igs;
            s/$h10/Hitai-ate/gs;
            s/$h11/Hunter-Nin/gs;
            print "\b\b\b70\%";
            #I
            s/$i1/Invisibility Cloak/gs;
            s/$i2/Ice Cream/gs;
            s/$i3/Imperius \u$1/gs;
            #J
            s/$j1/Jutsu/gs;
            s/$j2/Jinch&#363\;riki/igs;
            s/$j3/J&#333\;nin/igs;
            s/$j4/J&#363\;ken/igs;
            s/$j5/$1 \l$2/igs;
            s/$j6/Jelly-Legs/gs;
            #K
            s/$k1/Know-It-All/gs;
            s/$k2/Kekkei Genkai/gs;
            s/$k3/Kneazle/igs;
            s/$k4/Ky&#363\;bi/igs;
            #L
            s/$l1/\u$1-in-Law/igs;
            s/$l2/Lemon Drop/gs;
            s/$l3/Leaky Cauldron/gs;
            s/$l4/Legilimency/gs;
            #M
            s/$m1/Muggleborn/gs;
            s/$m4/Mundaneborn/gs;
            s/$m2/Martial Art/gs;
            s/$m3/\u$1 \u$2/g; #~~M and W~~
            #N
            s/$n1/Notice-Me-Not/igs;
            s/$n2/NEWT\l$1/gs;
            s/$n3/$1a&iuml;ve/gs;
            #O
            s/$o1/Order of the Phoenix/igs;
            s/$o2/Occlumency/igs;
            s/$o3/OWL\l$1/gs;
            s/$o4/&\#332\;noki/gs;
            print "\b\b\b80\%";
            #P
            s/$p1/Portrait Hole/igs;
            s/$p2/Privet Drive/igs;
            s/$p3/Quidditch Pitch/igs;
            s/$p4/Pumpkin Juice/igs;
            s/$p5/Petrificus Totalus/igs;
            s/$p6/Prophecy/igs;
            s/$p7/Pomfrey/igs;
            s/$p8/Parseltongue/igs;
            s/$p9/Parsel Magic/gs;
            s/$p10/Professor/igs;
            s/$p11/Patronus/igs;
            s/$p12/practic$1/igs;
            s/$p13/Parselmouth/igs;
            s/$p14/Pepper-Up/gs;
            s/$p15/Prank War/gs;
            #Q
            
            #R
            s/$r1/\u$1 Room/igs;
            s/$r2/Room of Requirement/igs;
            s/$r3/\u$1 Ring/igs;
            s/$r4/$1 Ring/gs;
            s/$r5/Rookie \u$1/gs;
            #S
            s/$s1/Secret Keeper/igs;
            s/$s2/Shrieking Shack/igs;
            s/$s3/Sorting Hat/igs;
            s/$s4/Soul Mate/igs;
            s/$s5/Spell Crafting/igs;
            s/$s6/\u$1 Stone/igs;
            s/$s7/shunshin/igs;
            s/$s8/Sexy-no-Jutsu/igs;
            s/$s9/\u$1 \u$2/igs;
            s/$s10/Summon Boss/gs;
            s/$s11/Samehada/igs;
            s/$s12/Skele-Grow/gs;
            #T
            s/$t1/Time Turner/igs;
            s/$t2/\u$1 Tree/igs;
            s/$t3/$1 \u$2/gs;
            #U
            s/$u1/Unbreakable Vow/igs;
            #V
            
            #W
            s/$w1/Whiskey/gs;
            #X
            
            #Y
            s/$y1/Y&#333\;ko/igs;
            s/$y2/\u$1 \u$2/igs;
            #Z
            #
        }
        print "\b\b\b90\%";
        $body = $_;
        $lines = $head . $body;
        if ($lines !~ /^$/) {
            open (OUT, ">$dir$f") or die "Can't open $dir$f: $!\n";
            print OUT "$lines";
            close OUT;
        }
        else {
            print "\n\nERROR! Empty file created\n\n";
            system("pause");
            exit(1)
        }
    }
    #=======================================================================================================================
        # Second loop through the file. Fixes summary.
    #=======================================================================================================================
    if ($secondloop == 1) {
        open (IN, "<$dir$f") or die "Can't open $dir$f: $!\n";
        @lines = <IN>;
        close IN;
        open (OUT, ">$dir$f") or die "Can't open $dir$f: $!\n";
        for ( @lines ) {
            if ($_ =~ /($postbody_regex)/i) { $postbody = "true"; }
            #The following IF-ELSE is designed to insert and format the ebook summary.
            if ($postbody eq "true") {
                $i++ if $status==1;
                
                $status=1 if ($_ =~ m/<H1>/i);        #<H1> indicates the title. Here i=0 and iteration must complete before i=1;
                #i=1 will in dicate the <h2> line that marks the author.
                if ($i==2) {                          #i=2 is where a <HR> tag should be.
                    if ($_ !~ m/<HR>/i) {               #if <HR> is found, do nothing and move on.
                        if ($_ =~ m/$hrbreak/i) {         #if statement checks for $hrbreak. If found inserts the necessary <HR> before it.
                            $_ = "<HR>\n$_";
                            $i=3;                           #We know that there is already a $hrbreak so we can skip next iteration.
                        }
                        elsif ($_ =~ m/Summary:/i) {      #check line for summary. If found fills in necessary <HR> and $hrbreak before it.
                            $_ = "<HR>\n$hrbreak\n$_";
                            $i=4;                           #summary already found. Can skip to 5th and final iteration of statement.
                        }
                        elsif ($_ =~ m/$del/i) { $i=1; }  #This is due to the fact that removing lines such as "<P> </P>" takes an extra loop.
                        else {                            #If none of neccesary info found. Insert all and then stop all iterations.
                            $_ = "<HR>\n$hrbreak\n$sstring\n$hrbreak\n$_";
                            $i=0;                           #stops iterations.
                            $status=0;                      #switches of $i incrementations.
                        }
                    }
                }
                elsif ($i==3) {                       #i=3 is where $hrbreak should be.
                    if ($_ !~ m/$hrbreak/i) {           #if $hrbreak is found, do nothing.
                        if ($_ =~ m/Summary:/i) {         #if statement checks for summary. If found inserts the necessary $hrbreak before it.
                            $_ = "$hrbreak\n$_";
                            $i=4;                           #summary already found. Can skip to 5th and final iteration of statement.
                        }
                        elsif ($_ =~ m/<H2>/i) { $i=1; }  #This is due to the fact that removing lines such as "<P> </P>" takes an extra loop.
                        elsif ($_ =~ m/$del/i) { $i=2; }  #This is due to the fact that removing lines such as "<P> </P>" takes an extra loop.
                        else {
                            $_ = "$hrbreak\n$sstring\n$hrbreak\n$_";
                            $i=0;                           #stops iterations.
                            $status=0;                      #switches of $i incrementations.
                        }
                    }
                }
                elsif ($i==4) {                       #i=4 is where summary should be.
                    if ($_ !~ m/summary:/i) {           #if summary is found, do nothing.
                        if ($_ =~ m/$hrbreak/i) {         #if statement checks for $hrbreak. If found inserts the necessary summary before it.
                            $_ = "$sstring\n$_";
                            $i=0;                           #stops iterations.
                            $status=0;                      #switches of $i incrementations.
                        }
                        elsif ($_ =~ m/$del/i) { $i=3; }  #This is due to the fact that removing lines such as "<P> </P>" takes an extra loop.
                        else {
                            $_ = "$sstring\n$hrbreak\n$_";
                            $i=0;                           #stops iterations.
                            $status=0;                      #switches of $i incrementations.
                        }
                    }
                }
                elsif ($i==5) {                       #i=5 is where final $hrbreak should be.
                    if ($_ =~ m/$del/i) { $i=4; }       #This is due to the fact that removing lines such as "<P> </P>" takes an extra loop.
                    else {
                        $_ = "$hrbreak\n$_" if ($_ !~ m/$hrbreak/i);
                        $i=0;                             #stops iterations.
                        $status=0;                        #switches of $i incrementations.
                    }
                }
            }
            
            #--------------------------------------------------------------------------------------------------------------------------------------------
            print OUT unless (m/$del/);             #$del used to delete entire lines.
        }
        #-Finish up:- Last commands before ending file
        close OUT;
        
        {
            open (IN, "<$dir$f") or die "Can't open $dir$f: $!\n";
            local $/;
            $fnew = <IN>;
            close IN;
        }
        #Keep running substitutions until there are no more changes to file.
        if (($fnew ne $forig)&&($loop<=10)&&($repeatloop == 1)) {
            print "\b\b\b";
            system("C:/Program Files/Tidy/tidy", "-o", "$dir$f", "-config", "C:/Program Files/Tidy/config.txt", "$dir$f");
            goto START;
        }
        else {
            #Debug
            if ($loop > 10) {
                open (OUT1, ">>$debug") or die "$debug: $!\n";
                print OUT1 "$dir$f\n";
                close OUT1;
            }
            print "\b\b\bComplete\n\tSecond Tidy: ";
            system("C:/Program Files/Tidy/tidy", "-o", "$dir$f", "-config", "C:/Program Files/Tidy/config.txt", "$dir$f");
            print "Complete\n";
            $loop = 0;
        }
    }
    
}
#end timer
$end = time();
$minutes = 0;
$seconds = ($end - $start);
while ($seconds > 59) {
    $minutes++;
    $seconds -= 60;
}
if ($minutes > 0) { print "\nTime taken: $minutes minutes $seconds seconds\n"; }
else { print "\nTime taken: $seconds seconds\n"; }
#-----------------------------
print "\nCleanup of File(s) complete. Exiting in 2 seconds\n";
sleep(2);
exit(0);