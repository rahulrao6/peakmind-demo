import pandas as pd

# Load the dataset
file_path = 'mental_data.csv'
df = pd.read_csv(file_path)

# Drop the 'Entity' and 'index' columns if they exist, as they are not needed for the analysis
df.drop(columns=['Entity', 'index'], inplace=True, errors='ignore')

# List of all columns we're interested in
all_cols = [
    'Code', 'Year', 'Schizophrenia (%)', 'Bipolar disorder (%)', 'Eating disorders (%)',
    'Anxiety disorders (%)', 'Drug use disorders (%)', 'Depression (%)', 
    'Alcohol use disorders (%)'
]

# Convert all percentage columns to float, removing any non-numeric characters that could interfere
cols_to_convert = all_cols[2:]  # Exclude 'Code' and 'Year' for conversion to float

for col in cols_to_convert:
    # Remove any commas from the numbers which can prevent proper conversion to float
    df[col] = df[col].replace(',', '', regex=True)
    df[col] = pd.to_numeric(df[col], errors='coerce')

# Drop rows where any of the required data is missing
df.dropna(subset=all_cols, inplace=True)

# After dropping rows with missing data, let's check the remaining data
print(df.info())  # Should display information about the DataFrame and confirm no null values

# Save the cleaned data
cleaned_file_path = 'cleaned_mental_data.csv'
df.to_csv(cleaned_file_path, index=False)

print("Data cleaned. Rows with missing data removed. Data saved to:", cleaned_file_path)


# RAJ - THIS SHOULD ALL BE STORED IN FIREBASE AND THEN RETRIEVED FOR THE MODEL
questionnaire_plan = {
    "Anxiety": {
        1: {"description": "Severe anxiety very often", "action": "2 min deep breathing, 2 min stretching, 1 minute of positive affirmation"},
        2: {"description": "Frequent anxiety difficult to manage", "action": "Box Breathing - 4/4/4"},
        3: {"description": "Regular anxiety at a manageable level", "action": "Create list of habits for positive anxiety management"},
        4: {"description": "Noticeable but non problematic", "action": "Set a reminder for a self care practice you neglect related to your anxieties"},
        5: {"description": "Very minimal anxiety, if any", "action": "Try out mindfulness stretching"}
    },
    "Current Mental State": {
        1: {"description": "Very negative baseline headspace", "action": "Develop a personal safety plan for your times when you struggle most"},
        2: {"description": "Somewhat negative baseline headspace", "action": "Create a 'calm' kit - a kit of items to reduce stress during particularly painful times"},
        3: {"description": "Neither positive nor negative headspace", "action": "Purchase yourself a gift"},
        4: {"description": "Somewhat positive baseline headspace", "action": "Set 2 goals for your mental state"},
        5: {"description": "Very positive baseline headspace", "action": "Repeat 5 positive affirmations to yourself for 3 days"}
    },
    "Self-Care abilities": {
        1: {"description": "Poor, rare self care", "action": "Hold a self care day"},
        2: {"description": "Occasional self care once in a while", "action": "Hold a self care night"},
        3: {"description": "Mediocre, sporadic self care", "action": "Journal Entry - 'Self Care Struggles' - Which elements of self care do you most struggle with?"},
        4: {"description": "Somewhat regular self care, a few times a week", "action": "Plan a weekly self care routine"},
        5: {"description": "Excellent, regular self care", "action": "Relax!!"}
    },
    "Support System": {
        1: {"description": "Very negative or not developed", "action": "List out members who could be a part of your support system"},
        2: {"description": "Not very effective, but there", "action": "Call or text someone from your support system"},
        3: {"description": "Decent, sometimes there as expected", "action": "Write a letter to someone you love"},
        4: {"description": "Good, usually there when needed", "action": "Reach out to someone in your support system"},
        5: {"description": "Excellent, very effective support system", "action": "meet up with a friend"}
    },
    "Stress": {
        1: {"description": "Severe, frequent stress", "action": "Test progressive muscle relaxation"},
        2: {"description": "Moderate stress on a regular basis", "action": "5-minute meditation"},
        3: {"description": "Mild stress on a semi regular basis", "action": "Identify 3 sources of stress and when they typically surface"},
        4: {"description": "Some stress in sporadic times", "action": "Give yourself a physical reward for overcoming your next stressful situation"},
        5: {"description": "Little to no stress", "action": "Repeat 5 things you are grateful for, 3 days straight"}
    },
    "Eating": {
        1: {"description": "Severe Inconsistent Eating", "action": "Journal Entry - 'Food Relationship' - Describe your relationship with food."},
        2: {"description": "Regular struggles at meal times", "action": "Create a list of safe foods for when you're struggling"},
        3: {"description": "Inconsistent eating tendencies on a daily basis", "action": "Try to eat a food you typically uncomfortable with - exposure therapy"},
        4: {"description": "Occasional struggles with over/under eating", "action": "Treat yourself to your favorite food"},
        5: {"description": "Perfectly Normal", "action": "Have some Water"}
    }
}



feature_to_concept = {
    'Schizophrenia (%)': 'Current Mental State',
    'Bipolar disorder (%)': 'Current Mental State',
    'Eating disorders (%)': 'Eating',
    'Anxiety disorders (%)': 'Anxiety',
    'Drug use disorders (%)': 'Self-Care abilities',
    'Depression (%)': 'Support System',
    'Alcohol use disorders (%)': 'Self-Care abilities'

}


import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor

# Load the dataset
file_path = 'cleaned_mental_data.csv'
df = pd.read_csv(file_path)

# Define the mappings from questionnaire concepts to dataset columns
concept_to_columns = {
    "Anxiety": "Anxiety disorders (%)",
    "Current Mental State": ["Schizophrenia (%)", "Bipolar disorder (%)", "Depression (%)"],
    "Self-Care abilities": ["Drug use disorders (%)", "Alcohol use disorders (%)"],
    "Support System": ["Depression (%)", "Drug use disorders (%)", "Alcohol use disorders (%)"],
    "Stress": "Anxiety disorders (%)",
    "Eating": "Eating disorders (%)"
}

# Raj - THIS IS A PLACEHOLDER FOR RESPONSES - RESPONSES SHD COME FROM FIREBASE AND BE PUT INTO THIS FORMAT

# Define individual's responses to the questionnaire
individual_responses = {
    "Anxiety": 3,
    "Current Mental State": 2,
    "Self-Care abilities": 4,
    "Support System": 3,
    "Stress": 1,
    "Eating": 2
}

# Prepare the features and target for modeling, using one of the conditions as an example target
features = df.drop(columns=['Code', 'Year', 'Anxiety disorders (%)'])
target = df['Anxiety disorders (%)']

# Split the dataset into training and testing sets
X_train, X_test, y_train, y_test = train_test_split(features, target, test_size=0.2, random_state=42)

# Initialize and train the RandomForestRegressor
model = RandomForestRegressor(n_estimators=100, random_state=42)
model.fit(X_train, y_train)

# Extracting feature importances
importances = model.feature_importances_


# Combine all tasks from the questionnaire_plan
all_tasks = []
for concept, levels in questionnaire_plan.items():
    for level in levels.values():
        all_tasks.append(level['action'])

# Deduplicate tasks
unique_tasks = list(set(all_tasks))

# Prepare tasks with their adjusted priority based on feature importance
tasks_with_priority = []
for feature, importance in zip(features.columns, importances):
    concept = feature_to_concept.get(feature)
    if concept:
        response_level = individual_responses.get(concept, 3)  # Default to a neutral response level if not provided
        action = questionnaire_plan[concept][response_level]['action']
        # Add task with priority if it's in the unique tasks list
        if action in unique_tasks:
            tasks_with_priority.append((importance, action))
            unique_tasks.remove(action)  # Remove from unique tasks to avoid duplicates

# Sort tasks by their priority
tasks_with_priority.sort(reverse=True, key=lambda x: x[0])

# Extracting and printing sorted actions
print("Personalized Action Plan (Sorted by Importance):")
for _, action in tasks_with_priority:
    print(action)

# Add remaining tasks that were not covered by the model's feature importances
# These tasks are considered to have the lowest priority for this individual's plan

sorted_actions = [action for _, action in tasks_with_priority] + unique_tasks



# Raj - THIS IS A PLACEHOLDER FOR THE FINAL ACTION -> THIS LIST SHD GO TO FIREBASE AND THEN MIKEY CAN ACCESS

# Print the final sorted list of all actions
print("\nComplete Personalized Action Plan:")
for action in sorted_actions:
    print(action)
