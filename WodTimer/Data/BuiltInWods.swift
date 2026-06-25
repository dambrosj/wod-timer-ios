import Foundation

enum BuiltInWods {
    static var all: [SavedWod] { seeds.compactMap { $0 } }

    private static let now = Date().timeIntervalSince1970

    private static func make(id: String, name: String, description: String,
                              isFavourite: Bool = false, isBuiltIn: Bool = true,
                              config: TimerConfig) -> SavedWod? {
        guard let json = try? config.encoded() else { return nil }
        return SavedWod(id: id, name: name, type: config.timerType,
                        configJson: json, description: description,
                        createdAt: now,
                        isFavourite: isFavourite, isBuiltIn: isBuiltIn)
    }

    // MARK: – Built-in benchmark WODs

    private static let tabataClassico = make(
        id: "built_in_tabata_classico",
        name: "Tabata Classico",
        description: "Il protocollo Tabata originale: 8 serie da 20s lavoro / 10s riposo.",
        config: .tabata(.init(series: 8, workSeconds: 20, restSeconds: 10))
    )

    private static let bodyWeight = make(
        id: "built_in_body_weight",
        name: "Body Weight",
        description: "Tabata esteso a corpo libero: 20 serie da 30s lavoro / 15s riposo.",
        config: .tabata(.init(series: 20, workSeconds: 30, restSeconds: 15))
    )

    private static let cindy = make(
        id: "built_in_cindy",
        name: "Cindy",
        description: "AMRAP 20 min: 5 trazioni, 10 piegamenti, 15 squat.",
        config: .amrap(.init(durationSeconds: 20 * 60,
                             exercises: ["5 trazioni", "10 piegamenti", "15 squat"]))
    )

    private static let fran = make(
        id: "built_in_fran",
        name: "Fran",
        description: "For Time (timecap 10 min): 21-15-9 thruster + trazioni.",
        config: .forTime(.init(timecapSeconds: 10 * 60, rounds: 1,
                               exercises: ["21 thruster", "21 trazioni",
                                           "15 thruster", "15 trazioni",
                                           "9 thruster",  "9 trazioni"]))
    )

    private static let murph = make(
        id: "built_in_murph",
        name: "Murph",
        description: "For Time (timecap 60 min): 1 miglio corsa, 100 trazioni, 200 piegamenti, 300 squat, 1 miglio corsa.",
        config: .forTime(.init(timecapSeconds: 60 * 60, rounds: 1,
                               exercises: ["1 miglio corsa", "100 trazioni",
                                           "200 piegamenti", "300 squat",
                                           "1 miglio corsa"]))
    )

    // MARK: – Personal WODs (stable UUIDs)

    private static let wodSolito = make(
        id: "a17bee12-1753-4e92-ad7c-4d433a7d6121",
        name: "WOD SOLITO",
        description: "3×8 — 33s lavoro / 15s riposo",
        isFavourite: true, isBuiltIn: false,
        config: .tabata(.init(
            series: 8, workSeconds: 33, restSeconds: 15,
            exercises: ["Push-up", "Clean & Jerk", "Pull-up", "GTH kettleball",
                        "Dips", "Russian crunch dumbell", "Curl", "Core Superman hollow"]
        ))
    )

    private static let wormUp = make(
        id: "7ee9feed-9dff-4f09-9397-0676723182b5",
        name: "WORM-UP",
        description: "12×20s lavoro / 10s riposo",
        isFavourite: true, isBuiltIn: false,
        config: .tabata(.init(series: 12, workSeconds: 20, restSeconds: 10))
    )

    private static let fullBodyResistanceBand = make(
        id: "bab89276-2632-4207-8678-7e285727eec5",
        name: "Full body resistance band",
        description: "3×11 — 40s lavoro / 15s riposo / 2:25 riposo tra i round",
        isFavourite: true, isBuiltIn: false,
        config: .tabata(.init(
            series: 11, workSeconds: 40, restSeconds: 15,
            exercises: ["Thruster", "Seated row", "Facepull", "Deadlift", "Upright row",
                        "Pull aparts", "Squats", "X band shuffle",
                        "Curl sx", "Curl dx", "Tricep extension"],
            wodRepeat: WodRepeatConfig(wodRounds: 3, restBetweenRoundsSeconds: 145)
        ))
    )

    private static let defaticamentoStretching = make(
        id: "4574c156-3a8e-4781-b367-78cd6a5af0a3",
        name: "D & S",
        description: "Defaticamento & Stretching",
        isFavourite: true, isBuiltIn: false,
        config: .custom(.init(intervals: [
            .init(name: "Mobilizzazione colonna",           durationSeconds: 30),
            .init(name: "Gamba tallone DX",                 durationSeconds: 30),
            .init(name: "Gamba tallone SX",                 durationSeconds: 30),
            .init(name: "Divaricata frontale",              durationSeconds: 20),
            .init(name: "Divaricata frontale DX",           durationSeconds: 30),
            .init(name: "Divaricata frontale SX",           durationSeconds: 30),
            .init(name: "Mobilizzazione colonna",           durationSeconds: 20),
            .init(name: "Incrocio Gamba SX",                durationSeconds: 30),
            .init(name: "Incrocio Gamba DX",                durationSeconds: 30),
            .init(name: "Mobilizzazione colonna",           durationSeconds: 20),
            .init(name: "Allungamento Laterale Braccio DX", durationSeconds: 30),
            .init(name: "Allungamento Laterale Braccio SX", durationSeconds: 30),
            .init(name: "Mano su pianta del piede DX",      durationSeconds: 20),
            .init(name: "Mano su pianta del piede SX",      durationSeconds: 20),
            .init(name: "Mobilizzazione colonna",           durationSeconds: 20),
            .init(name: "Spalla DX",                        durationSeconds: 20),
            .init(name: "Spalla SX",                        durationSeconds: 20),
            .init(name: "Pettorale DX",                     durationSeconds: 20),
            .init(name: "Pettorale SX",                     durationSeconds: 20),
            .init(name: "Frontale mani a terra",            durationSeconds: 30),
            .init(name: "Frontale a V",                     durationSeconds: 40),
            .init(name: "Mobilizzazione colonna a terra",   durationSeconds: 30),
            .init(name: "Allungamento schiena a terra",     durationSeconds: 30),
            .init(name: "Allungamento in affondo DX",       durationSeconds: 30),
            .init(name: "Allungamento in affondo SX",       durationSeconds: 30),
            .init(name: "Glutei back SX",                   durationSeconds: 30),
            .init(name: "Glutei back DX",                   durationSeconds: 30),
            .init(name: "Glutei front SX",                  durationSeconds: 30),
            .init(name: "Glutei front DX",                  durationSeconds: 30),
        ]))
    )

    private static let seeds: [SavedWod?] = [
        tabataClassico, bodyWeight, cindy, fran, murph,
        wodSolito, wormUp, fullBodyResistanceBand, defaticamentoStretching,
    ]
}
