#--
# Ruwiki
#   Copyright © 2002 - 2004, Digikata and HaloStatue
#   Alan Chen (alan@digikata.com)
#   Austin Ziegler (ruwiki@halostatue.ca)
#
# Licensed under the same terms as Ruby.
#
# $Id$
#++
class Ruwiki::Auth
  ROBOT_AGENTS = %r{
    (?:ChristCrawler.com|ChristCrawler@ChristCENTRAL.com) |
    (?:ComputingSite )?[Rr]obi |
    (?:Net|Web)Mechanic |
    (?:PerlCrawler|Xavatoria)/ |
    (?:pjspider|PortalJuice.com) |
    (?:spider_monkey|mouse.house) |
    (?:tach_bw|Black Widow) |
    (?:topiclink|TLSpider) |
    ahoy |
    AITCSRobot/ |
    AlkalineBOT |
    anthill |
    appie |
    Arachnophilia |
    arale |
    araneo |
    AraybOt |
    ArchitextSpider |
    ariadne |
    arks |
    Ask ?Jeeves/Teoma |
    ASpider/ |
    ATN_Worldwide |
    Atomz |
    AURESYS/ |
    BackRub/ |
    BaySpider |
    bbot |
    Big Brother |
    Bjaaland |
    BlackWidow |
    borg-bot/ |
    BotLink |
    boxseabot |
    BSpider/ |
    CACTVS Chemistry Spider |
    calif |
    Checkbot/ |
    cienciaficcion.net |
    CMCM/ |
    combine |
    confuzzledbot |
    CoolBot |
    cosmos |
    crawlpaper |
    cusco |
    cyberspyder |
    cydralspider |
    desert ?realm |
    Deweb/ |
    Die Blinde Kuh |
    dienstspider/ |
    digger |
    Digimarc CGIReader/ |
    Digimarc WebReader/ |
    DIIbot |
    dlw3robot/ |
    DNAbot/ |
    downloadexpress |
    DragonBot |
    Duppies |
    dwcp |
    ebiness |
    ecollector |
    EIT-Link-Verifier-Robot/ |
    elfinbot |
    Emacs-w3/ |
    EMC Spider |
    esculapio |
    ESI |
    esther |
    Evliya Celebi |
    explorersearch |
    fastcrawler |
    FDSE |
    FELIX ?IDE |
    fido |
    Fish-Search-Robot |
    fouineur |
    Freecrawl |
    FunnelWeb- |
    gammaSpider |
    gazz |
    gcreep |
    gestalttIconoclast/ |
    Getterrobo-?Plus |
    GetURL\.rexx |
    golem |
    googlebot |
    grabber |
    griffon |
    Gromit |
    gulliver |
    gulper |
    hambot |
    havIndex |
    HKU WWW Robot |
    Hometown Spider Pro |
    Hämähäkki |
    hotwired |
    htdig |
    htmlgobble |
    IAGENT/ |
    iajabot |
    IBM_Planetwide |
    image\.kapsi\.net |
    IncyWincy/ |
    Informant |
    InfoSeek Robot |
    Infoseek Sidewinder |
    InfoSpiders |
    INGRID/ |
    inspectorwww |
    Internet Cruiser Robot |
    irobot |
    Iron33 |
    IsraeliSearch/ |
    JavaBee |
    JBot |
    jcrawler |
    jobo |
    Jobot/ |
    JoeBot/ |
    JubiiRobot/ |
    jumpstation |
    Katipo/ |
    KDD-Explorer |
    KIT-Fireball |
    ko_yappo_robot |
    label-grabber |
    LabelGrab/ |
    larbin |
    legs |
    Linkidator |
    LinkScan (?:Server|Workstation) |
    linkwalker |
    Lockon |
    logo\.gif crawler |
    logo_gif_crawler |
    LWP |
    Lycos/ |
    M/ |
    Magpie/ |
    marvin |
    mattie |
    mediafox |
    MerzScope |
    MindCrawler |
    moget |
    MOMspider/ |
    Monster/v |
    Motor |
    msnbot |
    muncher |
    muninn |
    MuscatFerret |
    MwdSearch |
    NDSpider/ |
    NEC-MeshExplorer |
    Nederland.zoek |
    NetCarta CyberPilot Pro |
    NetScoop |
    newscan-online |
    NHSEWalker/ |
    Nomad |
    NorthStar |
    ObjectsSearch |
    Occam |
    Openfind |
    Orbsearch |
    packrat |
    pageboy |
    parasite |
    patric |
    PBWF |
    pegasus |
    Peregrinator-Mathematics/ |
    PGP-KA/ |
    phpdig |
    piltdownman |
    Pimptrain |
    Pioneer |
    PlumtreeWebAccessor |
    Poppi/ |
    PortalBSpider |
    psbot |
    Raven |
    Resume Robot |
    RHCS |
    RixBot |
    Road ?Runner |
    Robbie |
    RoboCrawl |
    robofox |
    Robot du CRIM |
    Robozilla/ |
    root/ |
    Roverbot |
    RuLeS/ |
    SafetyNet Robot |
    Scooter/? |
    Search-AU |
    searchprocess |
    Senrigan |
    SG-Scout |
    Shagseeker |
    Shai'Hulud |
    sharp-info-agent |
    SimBot |
    Site Valet |
    SiteTech-Rover |
    SLCrawler |
    Sleek Spider |
    slurp |
    snooper |
    solbot |
    speedy |
    SpiderBot/ |
    spiderline |
    SpiderMan |
    SpiderView |
    ssearcher |
    suke |
    suntek |
    sygol |
    T-H-U-N-D-E-R-S-T-O-N-E |
    Tarantula/ |
    tarspider |
    TechBOT |
    templeton |
    TITAN |
    titin |
    UCSD-Crawler |
    UdmSearch |
    udmsearch |
    Ukonline |
    uptimebot |
    URL Spider Pro |
    urlck |
    Valkyrie |
    verticrawl |
    Victoria |
    vision-search |
    void-bot |
    Voyager |
    VWbot_K |
    w[@a]p[sS]pider |
    w3index |
    W3M2/ |
    w3mir |
    WebBandit/ |
    webcatcher |
    WebCopy/ |
    WebFetcher/ |
    weblayers/ |
    WebLinker/ |
    WebMoose |
    webquest |
    webreaper |
    webs |
    webspider |
    webvac/ |
    webwalk |
    WebWalker |
    WebWatch |
    wget |
    whowhere |
    winona |
    wired-digital-newsbot/ |
    wlm |
    WOLP |
    WWWC |
    WWWWanderer |
    XGET
  }x

  BANNED_ROBOTS = %r{
    CherryPicker |
    Crescent Internet ToolPak |
    EmailCollector |
    EmailSiphon |
    EmailWolf |
    ExtractorPro |
    Microsoft URL Control
  }x

  class << self
    def [](name)
      @delegate ||= {}

      if @delegate.has_key?(name)
        @delegate[name]
      else
        require "ruwiki/auth/#{name}"
        @delegate[name] = Ruwiki::Auth.const_get(name.capitalize)
      end
    end

    def check_useragent(agent_string)
      case agent_string
      when ROBOT_AGENTS
        false
      when BANNED_ROBOTS
        nil
      else
        true
      end
    end
  end

  class Token
    def initialize(name = nil, groups = [], permissions = {})
      @user_name    = name
      @groups       = groups
      @permissions  = permissions
    end

    def found?
      not @user_name.nil?
    end

    def name
      @user_name
    end

    def member?(unix_group_name)
      @groups.include?(unix_group_name)
    end

    def groups
      @groups
    end

    def allowed?(action)
      @permission[action]
    end

    def permissions
      @permissions
    end
  end
end
