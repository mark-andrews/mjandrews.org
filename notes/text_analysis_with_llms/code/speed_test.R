free_text <- "
I didn't really want people to be afraid of me. I had taken a test and 
I knew I wasn't positive for Covid, so I was just worried that people would think
it was false and that they'd avoid me or get mad at me for attending when I was sick
"

instructions <- 'We have collected free response data from students at the University of Michigan
and healthcare workers within Michigan Medicine.
Your job will be to read through these free responses about why participants said they were motivated 
to hide signs of infectious illness and indicate where they fall on a number of different variables.

Does the participant mention motivations for concealment that were more related to the self or more 
related to others? Examples of self motivation include not wanting to miss out on in-person things
like work or class, not wanting others to judge them, not wanting others to avoid them.
Examples of other motivation include not wanting to worry other people, not wanting to burden
others by missing a work shift

Coding scheme: please put a "1" if it is a self motivation, a "2" if it is an other motivation,
and a "0" if it is neither/unclear.
Note: It is possible for a response to mention both self and other reasons, so it is ok for there
to be both a 1 and a 2 for the same response, i.e. "1,2".

Before answering, explain your reasoning step by step, using example phrases or words.
Then provide the final answer.

Your final answer should be either "0" or "1" or "2" or "1,2".

Format your response as a JSON object literal with keys "reasoning" and "answer".
The value of "reasoning" is your step by step reasoning, using phrases or words.
The value of "answer" is the numerical score ("0", "1", "2", or "1,2") that you assign
to the free response text.

And example of a JSON object literal response is this:

  {"reasoning": "The text shows many elements of a self motivation.",
  "answer": "1"}

Please make sure that there is an opening (left) and closing (right) curly brace in what you return.
If not, this is not a proper JSON object literal.
'

client <- ellmer::chat_ollama(model = "llama3.3", system_prompt = instructions)
results <- client$chat(free_text)