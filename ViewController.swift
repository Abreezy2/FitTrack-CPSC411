
import UIKit

// MARK: - Shared Design

enum FitStyle {
    static let background = UIColor(
        red: 0.07, green: 0.09, blue: 0.11, alpha: 1
    )

    static let card = UIColor(
        red: 0.15, green: 0.18, blue: 0.20, alpha: 1
    )

    static func title(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .boldSystemFont(ofSize: 30)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }

    static func button(_ text: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(text, for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 12
        button.heightAnchor.constraint(
            equalToConstant: 52
        ).isActive = true
        return button
    }

    static func backButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("← Back", for: .normal)
        button.setTitleColor(.systemGreen, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.heightAnchor.constraint(
            equalToConstant: 44
        ).isActive = true
        return button
    }

    static func centerStack(
        _ items: [UIView],
        in view: UIView,
        spacing: CGFloat = 18
    ) {
        let stack = UIStackView(arrangedSubviews: items)
        stack.axis = .vertical
        stack.spacing = spacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.centerYAnchor
            ),
            stack.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 30
            ),
            stack.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -30
            )
        ])
    }
}

// MARK: - Workout Data

struct WorkoutRecord {
    let muscleGroup: String
    let exercise: String
    let weight: Double
    let sets: Int
    let reps: Int
    let date: Date

    var volume: Double {
        weight * Double(sets * reps)
    }

    var dictionary: [String: Any] {
        [
            "muscleGroup": muscleGroup,
            "exercise": exercise,
            "weight": weight,
            "sets": sets,
            "reps": reps,
            "date": date.timeIntervalSince1970
        ]
    }

    init(
        muscleGroup: String,
        exercise: String,
        weight: Double,
        sets: Int,
        reps: Int,
        date: Date = Date()
    ) {
        self.muscleGroup = muscleGroup
        self.exercise = exercise
        self.weight = weight
        self.sets = sets
        self.reps = reps
        self.date = date
    }

    init?(dictionary: [String: Any]) {
        guard
            let group = dictionary["muscleGroup"] as? String,
            let exercise = dictionary["exercise"] as? String,
            let weight = dictionary["weight"] as? Double,
            let sets = dictionary["sets"] as? Int,
            let reps = dictionary["reps"] as? Int,
            let timestamp = dictionary["date"] as? Double
        else {
            return nil
        }

        self.init(
            muscleGroup: group,
            exercise: exercise,
            weight: weight,
            sets: sets,
            reps: reps,
            date: Date(timeIntervalSince1970: timestamp)
        )
    }
}

enum WorkoutStorage {
    static let key = "savedExercises"

    static func load() -> [WorkoutRecord] {
        let saved = UserDefaults.standard.array(
            forKey: key
        ) as? [[String: Any]] ?? []

        return saved.compactMap {
            WorkoutRecord(dictionary: $0)
        }
    }

    static func save(_ record: WorkoutRecord) {
        var saved = UserDefaults.standard.array(
            forKey: key
        ) as? [[String: Any]] ?? []

        saved.append(record.dictionary)
        UserDefaults.standard.set(saved, forKey: key)
    }
}

// MARK: - Home Screen

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = FitStyle.background

        let titleLabel = FitStyle.title("FIT TRACK")
        titleLabel.font = .boldSystemFont(ofSize: 36)

        let subtitle = UILabel()
        subtitle.text = "Your fitness journey starts here."
        subtitle.textColor = .lightGray
        subtitle.textAlignment = .center
        subtitle.numberOfLines = 0

        let start = FitStyle.button("Start Workout")
        let history = FitStyle.button("Workout History")
        let progress = FitStyle.button("My Progress")

        start.addTarget(
            self, action: #selector(startWorkout),
            for: .touchUpInside
        )

        history.addTarget(
            self, action: #selector(openHistory),
            for: .touchUpInside
        )

        progress.addTarget(
            self, action: #selector(openProgress),
            for: .touchUpInside
        )

        FitStyle.centerStack(
            [titleLabel, subtitle, start, history, progress],
            in: view,
            spacing: 24
        )
    }

    @objc func startWorkout() {
        let screen = WorkoutViewController()
        screen.modalPresentationStyle = .fullScreen
        present(screen, animated: true)
    }

    @objc func openHistory() {
        let screen = HistoryViewController()
        screen.modalPresentationStyle = .fullScreen
        present(screen, animated: true)
    }

    @objc func openProgress() {
        let screen = ProgressViewController()
        screen.modalPresentationStyle = .fullScreen
        present(screen, animated: true)
    }
}

// MARK: - Workout Selection

class WorkoutViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = FitStyle.background

        let titleLabel = FitStyle.title("Choose Your Workout")

        let groups = [
            "Chest", "Back", "Legs",
            "Shoulders", "Arms", "Abs"
        ]

        var items: [UIView] = [titleLabel]

        for group in groups {
            let button = FitStyle.button(group)

            button.addAction(
                UIAction { [weak self] _ in
                    self?.openExercises(group)
                },
                for: .touchUpInside
            )

            items.append(button)
        }

        let back = FitStyle.backButton()
        back.addTarget(
            self, action: #selector(goBack),
            for: .touchUpInside
        )

        items.append(back)
        FitStyle.centerStack(items, in: view, spacing: 16)
    }

    func openExercises(_ group: String) {
        let screen = ExerciseViewController()
        screen.muscleGroup = group
        screen.modalPresentationStyle = .fullScreen
        present(screen, animated: true)
    }

    @objc func goBack() {
        dismiss(animated: true)
    }
}

// MARK: - Exercise Tracker

class ExerciseViewController: UIViewController {

    var muscleGroup = ""
    var selectedExercise = ""

    let exercises: [String: [String]] = [
        "Chest": ["Bench Press", "Incline Press", "Chest Fly"],
        "Back": ["Lat Pulldown", "Barbell Row", "Pull Ups"],
        "Legs": ["Squats", "Leg Press", "Leg Curl"],
        "Shoulders": [
            "Shoulder Press", "Lateral Raise", "Rear Delt Fly"
        ],
        "Arms": ["Bicep Curl", "Tricep Pushdown", "Hammer Curl"],
        "Abs": ["Crunches", "Leg Raises", "Cable Crunch"]
    ]

    let exerciseButton = FitStyle.button("Choose Exercise")
    let weightField = UITextField()
    let setsField = UITextField()
    let repsField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = FitStyle.background

        let titleLabel = FitStyle.title("\(muscleGroup) Workout")

        exerciseButton.addTarget(
            self, action: #selector(chooseExercise),
            for: .touchUpInside
        )

        setupField(weightField, "Weight (lbs)", .decimalPad)
        setupField(setsField, "Number of Sets", .numberPad)
        setupField(repsField, "Reps per Set", .numberPad)

        let save = FitStyle.button("Save Exercise")
        save.addTarget(
            self, action: #selector(saveExercise),
            for: .touchUpInside
        )

        let back = FitStyle.backButton()
        back.addTarget(
            self, action: #selector(goBack),
            for: .touchUpInside
        )

        FitStyle.centerStack([
            titleLabel, exerciseButton,
            weightField, setsField, repsField,
            save, back
        ], in: view)

        let tap = UITapGestureRecognizer(
            target: self, action: #selector(hideKeyboard)
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    func setupField(
        _ field: UITextField,
        _ text: String,
        _ keyboard: UIKeyboardType
    ) {
        field.placeholder = text
        field.backgroundColor = .white
        field.textColor = .black
        field.borderStyle = .roundedRect
        field.keyboardType = keyboard
        field.heightAnchor.constraint(
            equalToConstant: 50
        ).isActive = true
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }

    @objc func chooseExercise() {
        let alert = UIAlertController(
            title: "Choose Exercise",
            message: nil,
            preferredStyle: .actionSheet
        )

        for exercise in exercises[muscleGroup] ?? [] {
            alert.addAction(
                UIAlertAction(
                    title: exercise, style: .default
                ) { [weak self] _ in
                    self?.selectedExercise = exercise
                    self?.exerciseButton.setTitle(
                        exercise, for: .normal
                    )
                }
            )
        }

        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel)
        )

        if let popover = alert.popoverPresentationController {
            popover.sourceView = exerciseButton
            popover.sourceRect = exerciseButton.bounds
        }

        present(alert, animated: true)
    }

    @objc func saveExercise() {
        guard
            !selectedExercise.isEmpty,
            let weightText = weightField.text,
            let weight = Double(weightText), weight >= 0,
            let setsText = setsField.text,
            let sets = Int(setsText), sets > 0,
            let repsText = repsField.text,
            let reps = Int(repsText), reps > 0
        else {
            showAlert(
                "Missing Information",
                "Choose an exercise and enter valid weight, sets, and reps."
            )
            return
        }

        let record = WorkoutRecord(
            muscleGroup: muscleGroup,
            exercise: selectedExercise,
            weight: weight,
            sets: sets,
            reps: reps
        )

        WorkoutStorage.save(record)

        showAlert(
            "Exercise Saved! 💪",
            "\(selectedExercise): \(sets) sets x \(reps) reps at \(weightText) lbs"
        )

        weightField.text = ""
        setsField.text = ""
        repsField.text = ""
        view.endEditing(true)
    }

    func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: "OK", style: .default)
        )
        present(alert, animated: true)
    }

    @objc func goBack() {
        dismiss(animated: true)
    }
}

// MARK: - Workout History with UITableView

class HistoryViewController: UIViewController,
                             UITableViewDataSource,
                             UITableViewDelegate {

    let tableView = UITableView()
    var records: [WorkoutRecord] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = FitStyle.background

        records = WorkoutStorage.load().reversed()

        let titleLabel = FitStyle.title("Workout History")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        tableView.backgroundColor = FitStyle.background
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 105
        tableView.separatorColor = .darkGray

        let back = FitStyle.backButton()
        back.translatesAutoresizingMaskIntoConstraints = false
        back.addTarget(
            self, action: #selector(goBack),
            for: .touchUpInside
        )

        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(back)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 20
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 20
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -20
            ),

            tableView.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor, constant: 20
            ),
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 20
            ),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -20
            ),
            tableView.bottomAnchor.constraint(
                equalTo: back.topAnchor, constant: -15
            ),

            back.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            back.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -20
            )
        ])

        if records.isEmpty {
            let empty = UILabel()
            empty.text = "No workouts saved yet."
            empty.textColor = .lightGray
            empty.textAlignment = .center
            tableView.backgroundView = empty
        }
    }

    // Required UITableViewDataSource method
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return records.count
    }

    // Required UITableViewDataSource method
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let identifier = "WorkoutCell"

        let cell = tableView.dequeueReusableCell(
            withIdentifier: identifier
        ) ?? UITableViewCell(
            style: .subtitle,
            reuseIdentifier: identifier
        )

        let record = records[indexPath.row]

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        cell.textLabel?.text =
            "\(record.muscleGroup) - \(record.exercise)"

        cell.detailTextLabel?.text = """
        \(record.sets) sets × \(record.reps) reps • \(record.weight.formatted()) lbs
        \(formatter.string(from: record.date))
        """

        cell.backgroundColor = FitStyle.card
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = .boldSystemFont(ofSize: 17)
        cell.detailTextLabel?.textColor = .lightGray
        cell.detailTextLabel?.numberOfLines = 2
        cell.selectionStyle = .none

        return cell
    }

    // Tap a saved workout to see its details
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let record = records[indexPath.row]

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        let message = """
        Muscle Group: \(record.muscleGroup)
        Exercise: \(record.exercise)
        Weight: \(record.weight.formatted()) lbs
        Sets: \(record.sets)
        Reps: \(record.reps)
        Date: \(formatter.string(from: record.date))
        """

        let alert = UIAlertController(
            title: "Workout Details",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: "OK", style: .default)
        )

        present(alert, animated: true)
    }

    @objc func goBack() {
        dismiss(animated: true)
    }
}

// MARK: - My Progress

class ProgressViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = FitStyle.background

        let records = WorkoutStorage.load()

        let totalExercises = records.count

        let totalSets = records.reduce(0) {
            $0 + $1.sets
        }

        let totalReps = records.reduce(0) {
            $0 + $1.sets * $1.reps
        }

        let totalVolume = records.reduce(0.0) {
            $0 + $1.volume
        }

        let days = Set(
            records.map {
                Calendar.current.startOfDay(for: $0.date)
            }
        ).count

        let titleLabel = FitStyle.title("My Progress 📈")

        let stats: [(String, String)] = [
            ("Exercises Logged", "\(totalExercises)"),
            ("Total Sets", "\(totalSets)"),
            ("Total Reps", "\(totalReps)"),
            ("Training Days", "\(days)"),
            ("Total Lifted Volume", "\(totalVolume.formatted()) lbs")
        ]

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        stack.addArrangedSubview(titleLabel)

        for (name, value) in stats {
            let card = UIView()
            card.backgroundColor = FitStyle.card
            card.layer.cornerRadius = 14

            let valueLabel = UILabel()
            valueLabel.text = value
            valueLabel.font = .boldSystemFont(ofSize: 27)
            valueLabel.textColor = .systemGreen
            valueLabel.textAlignment = .center
            valueLabel.adjustsFontSizeToFitWidth = true

            let nameLabel = UILabel()
            nameLabel.text = name
            nameLabel.textColor = .lightGray
            nameLabel.textAlignment = .center

            let inner = UIStackView(arrangedSubviews: [
                valueLabel, nameLabel
            ])
            inner.axis = .vertical
            inner.spacing = 8
            inner.translatesAutoresizingMaskIntoConstraints = false

            card.addSubview(inner)

            NSLayoutConstraint.activate([
                inner.topAnchor.constraint(
                    equalTo: card.topAnchor, constant: 18
                ),
                inner.bottomAnchor.constraint(
                    equalTo: card.bottomAnchor, constant: -18
                ),
                inner.leadingAnchor.constraint(
                    equalTo: card.leadingAnchor, constant: 12
                ),
                inner.trailingAnchor.constraint(
                    equalTo: card.trailingAnchor, constant: -12
                )
            ])

            stack.addArrangedSubview(card)
        }

        let back = FitStyle.backButton()
        back.addTarget(
            self, action: #selector(goBack),
            for: .touchUpInside
        )
        stack.addArrangedSubview(back)

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            scrollView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),
            scrollView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 25
            ),
            scrollView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -25
            ),

            stack.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor,
                constant: 20
            ),
            stack.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor,
                constant: -20
            ),
            stack.leadingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.leadingAnchor
            ),
            stack.trailingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.trailingAnchor
            ),
            stack.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor
            )
        ])
    }

    @objc func goBack() {
        dismiss(animated: true)
    }
}
