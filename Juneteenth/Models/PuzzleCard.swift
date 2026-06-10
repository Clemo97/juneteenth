import Foundation

// MARK: - PuzzleCard

struct PuzzleCard: Identifiable {
    let id: Int
    let imageName: String
    let title: String
    let subtitle: String
    let yearContext: String
    let historicalNote: String
}

// MARK: - Built-in cards

extension PuzzleCard {
    static let all: [PuzzleCard] = [
        PuzzleCard(
            id: 0,
            imageName: "puzzle_douglass",
            title: "Frederick Douglass",
            subtitle: "Abolitionist & Orator",
            yearContext: "1818 – 1895",
            historicalNote: "Born into slavery, Frederick Douglass taught himself to read and became one of history's most powerful voices for freedom. His autobiographies and speeches helped turn the tide of public opinion against slavery in America and abroad."
        ),
        PuzzleCard(
            id: 1,
            imageName: "puzzle_tubman",
            title: "Harriet Tubman",
            subtitle: "The Moses of Her People",
            yearContext: "c. 1822 – 1913",
            historicalNote: "Harriet Tubman escaped slavery and returned south at least 13 times, personally guiding some 70 enslaved people to freedom via the Underground Railroad. She famously said she never lost a single passenger."
        ),
        PuzzleCard(
            id: 2,
            imageName: "puzzle_galveston",
            title: "Galveston, Texas",
            subtitle: "The First Juneteenth",
            yearContext: "June 19, 1865",
            historicalNote: "On June 19, 1865, Union Major General Gordon Granger arrived in Galveston, Texas with General Order No. 3 — proclaiming that all enslaved people were free. The news came two and a half years after Lincoln's Emancipation Proclamation."
        ),
        PuzzleCard(
            id: 3,
            imageName: "puzzle_sojourner",
            title: "Sojourner Truth",
            subtitle: "Abolitionist & Suffragist",
            yearContext: "c. 1797 – 1883",
            historicalNote: "Born Isabella Baumfree into slavery in New York, Sojourner Truth became one of the era's most compelling speakers for both abolition and women's rights. Her 1851 speech, \"Ain't I a Woman?\", remains a landmark of American rhetoric."
        ),
        PuzzleCard(
            id: 4,
            imageName: "puzzle_flag",
            title: "The Juneteenth Flag",
            subtitle: "Symbol of Freedom",
            yearContext: "Designed 1997",
            historicalNote: "Designed by activist Ben Haith in 1997, the Juneteenth National Independence Flag features a star bursting on the horizon — the lone star of Texas, where freedom was proclaimed. The arc represents a new horizon of opportunity."
        )
    ]
}
