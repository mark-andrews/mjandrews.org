library(tidyverse)
library(readxl)
library(ellmer)
library(jsonlite)

set.seed(1010101)

fname <- "study_1_qualitative_coding_disc_con_xlsx" # Get this from https://osf.io/w8vbz

topics <- c("self-other", "harm", "stigma", "miss")

iterations <- 10

# ===================== Instructions =====================================================================
instructions_opening <- "
We have collected free response data from students at the University of Michigan and healthcare workers within Michigan Medicine.
Your job will be to read through these free responses about why participants said they were motivated to hide signs of infectious illness and indicate where they fall on a number of different variables.
"

instructions_closing <- "
Please make sure that there is an opening (left) and closing (right) curly brace in what you return.
If not, this is not a proper JSON object literal.
"

instructions <- list()

instructions[["self-other"]] <- '
Does the participant mention motivations for concealment that were more related to the self or more related to others?
Examples of self motivation include not wanting to miss out on in-person things like work or class, not wanting others to judge them, not wanting others to avoid them.
Examples of other motivation include not wanting to worry other people, not wanting to burden others by missing a work shift

Coding scheme: please put a "1" if it is a self motivation, a "2" if it is an other motivation, and a "0" if it is neither/unclear.
NOTE: It is possible for a response to mention both self and other reasons, so it is ok for there to be both a 1 and a 2 for the same response, i.e. "1,2".

Before answering, explain your reasoning step by step, using example phrases or words. Then provide the final answer.

Your final answer should be either "0" or "1" or "2" or "1,2".

Format your response as a JSON object literal with keys "reasoning" and "answer".
The value of "reasoning" is your step by step reasoning, using phrases or words.
The value of "answer" is the numerical score ("0", "1", "2", or "1,2") that you assign to the free response text.

And example of a JSON object literal response is this:

  {"reasoning": "The text shows many elements of a self motivation.",
  "answer": "1"}

'

instructions[["harm"]] <- '
Did the participant mention illness harm to others in their motivation response?
That is, did the response contain information about how harmful --- through symptom severity, symptom features, or perceived likelihood of transmitting --- their illness could be to others.
Examples of illness harm responses include talking about how mild their symptoms were
Coding scheme: please put a "1" if the response mentions illness harm to others, a "2" if it does not mention illness harm, and a "0" if you are unsure.

Before answering, explain your reasoning step by step, using example phrases or words. Then provide the final answer.

Your final answer should be either "0" or "1" or "2".

Format your response as a JSON object literal with keys "reasoning" and "answer".
The value of "reasoning" is your step by step reasoning, using phrases or words.
The value of "answer" is the numerical score ("0", "1", "2") that you assign to the free response text.

And example of a JSON object literal response is this:

  {"reasoning": "The text mentions symptom mildness",
  "answer": 1}

'

instructions[["stigma"]] <- "
Did the participant discuss motivations for concealment that mentioned feeling stigmatized, rejected, excluded, or isolated?
Examples of these responses could include saying that they didn't want to be judged, didn't want others to treat them differently, or didn't want others to avoid them.

Coding scheme: please put a '1' if the response involved rejection or isolation, a '2' if it does not include this, or a '0' if you are unsure.

Before answering, explain your reasoning step by step, using example phrases or words. Then provide the final answer.

Your final answer should be either '0' or '1' or '2'.

Format your response as a JSON object literal with keys 'reasoning' and 'answer'.
The value of 'reasoning' is your step by step reasoning, using phrases or words.
The value of 'answer' is the numerical score ('0', '1', '2') that you assign to the free response text.

And example of a JSON object literal response is this:

  {'reasoning': 'The text mentions that they did not wanted to judged or rejected.',
  'answer': '1'}

"

instructions[["miss"]] <- '
Did the participant mention concealing because they did not want to miss work or class?
Examples of these responses could be attending class because they had a group presentation, going to work because they felt pressured by their boss, or not wanting to burden their co-workers by missing work.
Coding scheme: put a "1" if the response mentions missing work or class, a "2" if it does not mention missing work or class, and a "0" if you are unsure.

Before answering, explain your reasoning step by step, using example phrases or words. Then provide the final answer.

Your final answer should be either "0" or "1" or "2".

Format your response as a JSON object literal with keys "reasoning" and "answer".
The value of "reasoning" is your step by step reasoning, using phrases or words.
The value of "answer" is the numerical score ("0", "1", "2") that you assign to the free response text.

And example of a JSON object literal response is this:

  {"reasoning": "The text mentions a class presentation.",
  "answer": 1}

'

results <- list()
topic_instructions <- list()
for (topic in topics) {
  results[[topic]] <- list()

  topic_instructions[[topic]] <- str_c(
    instructions_opening,
    instructions[[topic]],
    instructions_closing,
    sep = "\n"
  )

  data_df <- read_excel(fname, sheet = topic) |>
    select(id = ResponseId, free_text = motivation_fr, wg = WG, ra = RA)

  for (iter in seq(iterations)) {
    client <- chat_ollama(model = "llama3.3", system_prompt = topic_instructions[[topic]])
    results[[topic]][[iter]] <- map(data_df$free_text, client$chat)
  }

  saveRDS(results, file = "llama3.3_2024_12_30.Rds")
}
