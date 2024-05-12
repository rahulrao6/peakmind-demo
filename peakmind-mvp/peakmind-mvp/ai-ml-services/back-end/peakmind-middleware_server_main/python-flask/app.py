from flask import Flask, request, jsonify
import openai
from chat import main
from chat import update_context_summary
from ml_quiz_refactor import load_model 
app = Flask(__name__)


conversation_sessions = {}  # Define the conversation_sessions dictionary


@app.route('/chat', methods=['POST'])
def chat():
    user_input = request.json['message']
    # Example: Call to OpenAI's API
    response = "Hello from the AI chatbot"  # Placeholder response
    return jsonify({'response': response})

@app.route('/load-model', methods=['POST'])
def load_model_route():
    user_id = request.json['user_id']
    if user_id:
        load_model(user_id)
        return {'message': 'Model loaded successfully'}, 200
    else:
        return {'error': 'User ID not provided'}, 400


@app.route('/testchat', methods=['POST'])
def receive_request():
    user_input = request.json['message']
    conversation_id = request.json['user']
    print("this is hi from the flask server")
    # Ensure the conversation ID exists in the dictionary
    if conversation_id not in conversation_sessions:
        conversation_sessions[conversation_id] = {
            'history': [],  # Initialize empty conversation history
            'context_summary': {}  # Initialize empty context summary
        }
        
    conversation_history = conversation_sessions[conversation_id]['history']
    context_summary = conversation_sessions[conversation_id]['context_summary']

    ai_response = main(user_input, conversation_history, context_summary)

    # Append the user input and AI response to conversation history
    conversation_sessions[conversation_id]['history'].append({"role": "user", "content": user_input})
    conversation_sessions[conversation_id]['history'].append({"role": "assistant", "content": ai_response})

    # Update context summary based on the last user message
    if conversation_sessions[conversation_id]['history']:
        last_user_message = conversation_sessions[conversation_id]['history'][-2]["content"]
        context_summary = update_context_summary(last_user_message.lower(), context_summary)

    print(conversation_sessions)

    return jsonify({'response': ai_response, 'user': conversation_id}) 

if __name__ == '__main__':
    app.run(debug=True)