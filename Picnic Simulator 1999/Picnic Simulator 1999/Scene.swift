class Scene: Centaur {
    let title: String
    let choices: [String]

    init(text: String) {
        let parts = text.componentsSeparatedByString(" - ")
        title = parts[0]
        choices = parts[1].componentsSeparatedByString("/")
        super.init()
    }

    var textHeartbeat: RACSignal {
        var i = 0
        return RACSignal.interval(0.05, onScheduler: RACScheduler.mainThreadScheduler())
            .takeUntilBlock({ [unowned self] _ in i > self.title.characters.count })
            .map({
                [unowned self] (x) -> AnyObject! in
                let s = self.title.substringToIndex(self.title.startIndex.advancedBy(i))
                i += 1
                return s
            })
            .replayLast()
    }
}