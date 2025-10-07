//
//  UnscrambleGenerator.swift
//  CluoGames
//
//  Created by Assistant on 10/01/25.
//

import Foundation

struct UnscrambleGenerator {
    // Daily word list (5-7 letters), uppercase for consistency
    private static let dailyWords = [
        "ABLEST", "ABSORB", "ACCEPT", "ACCUSE", "ACROSS", "ACTION", "ADVICE", "AFFORD",
        "AGREED", "ALBUMS", "ALMOND", "ALMOST", "ALPINE", "AMBUSH", "AMONGS", "ANALOG",
        "ANCHOR", "ANGLED", "ANSWER", "ANYONE", "APPEAL", "APPLES", "ARTFUL", "ASCEND",
        "ATTEND", "AUTHOR", "AUTUMN", "AVENGE", "AVOCAD", "AWAKEN", "AWARDS", "BACKED",
        "BALLET", "BALLOON", "BAMBOO", "BANANA", "BANNER", "BARREL", "BASALT", "BASKET",
        "BEACON", "BEAUTY", "BEFORE", "BELIEF", "BENEATH", "BERLIN", "BERRY", "BEYOND",
        "BIRCH", "BLAZER", "BLENDS", "BLESSED", "BLINKS", "BLOOMS", "BLOSSOM", "BOUNCE",
        "BRANCH", "BRAVES", "BREATH", "BRIDGE", "BRIGHT", "BRONZE", "BUBBLE", "BUCKET",
        "BUTTER", "BUTTON", "CABBAGE", "CADETS", "CAESAR", "CAMERA", "CANDLE", "CANYON",
        "CANVAS", "CARBON", "CAREER", "CARPET", "CARTON", "CASHEW", "CASTLE", "CATNIP",
        "CATTLE", "CEDARS", "CELERY", "CENTER", "CHAIRS", "CHARTS", "CHEERS", "CHEESE",
        "CHERRY", "CHESTN", "CHICKS", "CHIMES", "CHOCOL", "CHOICE", "CHORUS", "CINEMA",
        "CITRUS", "CLARITY", "CLASSE", "CLOUDS", "COASTS", "COFFEE", "COMETS", "COMICS",
        "COMMON", "COMPACT", "CONTRA", "COOKED", "COPPER", "CORALS", "COTTAGE", "COTTON",
        "COYOTE", "CRANES", "CRATER", "CREATE", "CRESTS", "CRISPY", "CROWNS", "CRUISE",
        "CRUNCH", "CRYSTAL", "CUCUMB", "CULTIV", "CUPFUL", "CURVES", "CUSTOM", "CYCLER",
        "DAFFOD", "DANCER", "DAPPER", "DEBRIS", "DEEPER", "DELICA", "DELVES", "DEMAND",
        "DENTAL", "DEPICT", "DESERT", "DESIGN", "DETAIL", "DEVICE", "DIAMON", "DINING",
        "DINNER", "DOLPHI", "DONATE", "DOUBLE", "DRAGON", "DRAWER", "DREAMS", "DRIFTS",
        "DRIVER", "EARLY", "EARTH", "EASILY", "EATING", "ECONOM", "EDGING", "EDITOR",
        "EFFECT", "EGRETS", "EIGHTH", "ELBOWS", "ELDER", "ELEGAN", "ELEVEN", "ELMERS",
        "EMERAL", "EMPIRE", "ENACTS", "ENDURE", "ENERGY", "ENGAGE", "ENIGMA", "ENJOY",
        "ENOUGH", "ENSURE", "ENTER", "ENTITY", "ESCAPE", "ESSAYS", "ETHICS", "EVENING",
        "EVIDEN", "EXACTO", "EXCEED", "EXOTIC", "EXPAND", "EXPORT", "EXTEND", "FABRIC",
        "FACETS", "FACTOR", "FAMILY", "FAMOUS", "FARMER", "FASHION", "FASTEN", "FATHOM",
        "FAVOR", "FIGURE", "FILTER", "FINGER", "FIRMEN", "FISHER", "FLAMES", "FLEECE",
        "FLIGHT", "FLORAL", "FLOWER", "FLUFFY", "FLUIDS", "FLYERS", "FOCUS", "FOLLOW",
        "FOREST", "FORGOT", "FORMAT", "FOSSIL", "FOSTER", "FRAILS", "FRAZES", "FREELY",
        "FRESH", "FRIEND", "FRUITS", "GALAXY", "GARDEN", "GARLIC", "GENTLE", "GEYSER",
        "GIGGLE", "GINGER", "GLACER", "GLANCE", "GLIDER", "GLOBE", "GOLDEN", "GOOSE",
        "GOSPEL", "GRACE", "GRAINY", "GRAPES", "GRAVEL", "GRINDS", "GROOMS", "GROUND",
        "GROWTH", "GUITAR", "HABITS", "HAMMER", "HANDLE", "HARBOR", "HARMON", "HARVEST",
        "HEALTH", "HEARTS", "HEAVEN", "HELIUM", "HELPER", "HERBAL", "HIKERS", "HOLLOW",
        "HONEST", "HONEY", "HUMBLE", "HUNGER", "ICEBERG", "ICICLE", "IDEALS", "IMPACT",
        "IMPORT", "INSIDE", "ISLAND", "JACKET", "JASMINE", "JELLY", "JIGSAW", "JINGLE",
        "JOURNEY", "JUGGLE", "JUNIOR", "JUNGLE", "KETTLE", "KINDLY", "KITTEN", "LADDER",
        "LAGOON", "LAUNCH", "LAUREL", "LAVISH", "LAWYER", "LEAFY", "LEMONS", "LETTER",
        "LIBERT", "LIGHTS", "LILIES", "LIMBER", "LINENS", "LIONESS", "LIQUID", "LISTEN",
        "LIVING", "LOBBY", "LOFTY", "LOGGER", "LOTION", "LOUNGE", "LOVING", "LUCID",
        "LUNCH", "MAGNET", "MAGNOL", "MAJEST", "MANNER", "MAPLES", "MARBLE", "MARKET",
        "MARSH", "MASTER", "MEADOW", "MEDALS", "MEMORY", "MELLOW", "MERELY", "METALS",
        "METRIC", "MINGLE", "MINING", "MINUTE", "MIRROR", "MOBILE", "MODERN", "MONDAY",
        "MONKEY", "MOTHER", "MOTION", "MOUNTA", "MUFFIN", "MUSEUM", "MUSCLE", "MUSIC",
        "MYSTIC", "NARROW", "NATURE", "NEBULA", "NECTAR", "NESTED", "NEUTER", "NIMBLE",
        "NOBODY", "NORTH", "NOTIFY", "NUGGET", "NUMBER", "OBJECT", "OBLIGE", "OCEANS",
        "OCTAVE", "OLIVES", "ONIONS", "ORANGE", "ORCHID", "OUTFIT", "OUTING", "OUTLET",
        "OUTRIG", "OVERLY", "OWLERY", "OXFORD", "PAINTS", "PALACE", "PANDAS", "PAPER",
        "PARKER", "PARROT", "PASTEL", "PASTRY", "PATCHY", "PEACHY", "PEANUT", "PEARLS",
        "PEBBLE", "PELICA", "PEPPER", "PERSIM", "PHRASE", "PHYSIC", "PICNIC", "PIGEON",
        "PILLOW", "PINEAP", "PIONEER", "PIPING", "PIRATE", "PISTOL", "PITCHY", "PLACID",
        "PLANET", "PLANTS", "PLAQUE", "PLATED", "PLAYER", "PLOVER", "POCKET", "POLISH",
        "PONDERS", "POPCOR", "POPPY", "PORTAL", "POTATO", "POWDER", "PRAISE", "PRANCE",
        "PRAWNS", "PREFAB", "PRETTY", "PRIMER", "PRINCE", "PROFIT", "PROTON", "PUFFIN",
        "PURPLE", "PUZZLE", "QUAINT", "QUARTZ", "QUEENS", "QUENCH", "QUIET", "QUILLS",
        "QUOKKA", "RABBIT", "RADIAL", "RADISH", "RAINFO", "RAISIN", "RANGER", "RAPIDS",
        "REACTS", "REALLY", "REBORN", "RECENT", "RECIPE", "REFINE", "REFORM", "REGION",
        "REJOIC", "RELATE", "RELIAB", "RENEW", "REPAIR", "REPORT", "RESCUE", "RESORT",
        "RETURN", "REWARD", "RHINOS", "RHYTHM", "RIBBON", "RIDDLE", "RIDERS", "RIPPLE",
        "RISING", "RIVERS", "ROCKET", "ROOSTS", "ROUNDE", "RUBBER", "RUSTIC", "SAFARI",
        "SAFFRO", "SAILOR", "SALMON", "SANDAL", "SANDER", "SAVORY", "SCENIC", "SCHOOL",
        "SCONCE", "SCOUTS", "SEASON", "SEEDER", "SELDOM", "SENSES", "SENTIN", "SEPTEM",
        "SERENE", "SHADOW", "SHAKEN", "SHAPED", "SHEARS", "SHEPHER", "SHINER", "SHIVER",
        "SHRIMP", "SILENT", "SILVER", "SIMPLE", "SINCER", "SINGER", "SISTER", "SKETCH",
        "SKYLINE", "SLIDER", "SMOOTH", "SMUDGE", "SNACKS", "SNAKES", "SNEAKS", "SNOWED",
        "SOCKET", "SOLACE", "SOUNDS", "SOURCE", "SPARRO", "SPARKS", "SPEAKS", "SPICES",
        "SPIDER", "SPIRAL", "SPLASH", "SPOKEN", "SPORTS", "SPRING", "SPROUT", "SQUARE",
        "SQUEAK", "STABLE", "STACKS", "STAIRS", "STAKES", "STARLY", "STATUS", "STEADY",
        "STEAMY", "STITCH", "STOCKS", "STONE", "STOOLS", "STORMY", "STOVES", "STREAM",
        "STRIPE", "STRIVE", "STRONG", "STUDIO", "SUBTLE", "SUGARY", "SUMMER", "SUNLIT",
        "SUNNY", "SUNSET", "SUPPLY", "SWERVE", "SWIFT", "SWIRLS", "SWOOP", "SYRUPS",
        "TABLET", "TALENT", "TANGER", "TAROT", "TASTED", "TEACUP", "TEAPOT", "TEETHS",
        "TEMPLE", "TENANT", "TENDER", "TENNIS", "TERRAC", "THRIVE", "THRUSH", "THYME",
        "TICKET", "TIGERS", "TIMBER", "TISSUE", "TOMATO", "TONGUE", "TOUCAN", "TRAVEL",
        "TREATY", "TREEFO", "TRICOT", "TRIPLE", "TROPIC", "TRUFFL", "TRUSTY", "TULIPS",
        "TUMBLE", "TURKEY", "TURTLE", "TWIGGY", "TWILIG", "UNION", "UNPACK", "UPLIFT",
        "URCHIN", "VACUUM", "VALLEY", "VELVET", "VELVET", "VERBAL", "VERTEX", "VESSEL",
        "VIABLE", "VIBRAN", "VIOLET", "VIRGIN", "VISION", "VISUAL", "VIVIEN", "VOLCAN",
        "VOYAGE", "WALNUT", "WARMTH", "WATERS", "WEALTH", "WEAVER", "WEIGHT", "WHEELS",
        "WHISPER", "WIDGET", "WILLOW", "WINNER", "WINTER", "WISDOM", "WONDER", "WOODEN",
        "WORKER", "WORLD", "WOVENS", "WRITER", "YACHTS", "YELLOW", "YOGURT", "YOUNGS",
        "ZEALOT", "ZEBRAS", "ZENITH"
    ]
    
    static func dailyWord(for date: Date = Date()) -> String {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        let index = (dayOfYear - 1) % dailyWords.count
        return dailyWords[index]
    }

    static func word(forSeed seed: String) -> String {
        let hash = djb2(seed)
        let index = Int(hash % UInt64(dailyWords.count))
        return dailyWords[index]
    }
    
    static func scrambleWord(_ word: String) -> String {
        let characters = Array(word.uppercased())
        var scrambled = characters.shuffled()
        
        // Ensure it's not the same as original
        while String(scrambled) == word.uppercased() && characters.count > 1 {
            scrambled = characters.shuffled()
        }
        
        return String(scrambled)
    }
    
    static func generateDailyGame(for date: Date = Date()) -> UnscrambleGame {
        let word = dailyWord(for: date)
        return UnscrambleGame(date: date, word: word)
    }
    
    static func generateGame(seed: String, date: Date = Date()) -> UnscrambleGame {
        let word = word(forSeed: seed)
        return UnscrambleGame(date: date, word: word)
    }
    
    static func isValidWord(_ word: String) -> Bool {
        // Basic validation - could be enhanced with a dictionary
        return word.count >= 5 && word.count <= 7 && word.allSatisfy { $0.isLetter }
    }
}

// MARK: - Simple deterministic hash (djb2)
private func djb2(_ string: String) -> UInt64 {
    var hash: UInt64 = 5381
    for byte in string.utf8 {
        hash = ((hash << 5) &+ hash) &+ UInt64(byte) // hash * 33 + byte
    }
    return hash
}
