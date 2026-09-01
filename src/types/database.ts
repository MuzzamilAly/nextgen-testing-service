export type ContentStatus = "draft" | "published" | "archived";
export type UserRole = "student" | "admin";
export type AnswerOption = "a" | "b" | "c" | "d";
export type QuestionDifficulty = "easy" | "medium" | "hard";
export type AttemptStatus = "in_progress" | "submitted" | "abandoned";
export type AssessmentType = "mock_test" | "practice_quiz";
export type SubscriptionStatus = "active"|"expired"|"cancelled";
type Table<Row, Insert = Partial<Row>, Update = Partial<Insert>> = { Row: Row; Insert: Insert; Update: Update; Relationships: [] };
type Audit = { created_at: string; updated_at: string };

export type Database = { public: {
  Tables: {
    profiles: Table<{
      id:string; full_name:string|null; email:string; phone:string|null; profile_photo:string|null; role:UserRole;
      target_university_id:string|null; target_program_id:string|null; created_at:string; updated_at:string;
    },{id:string;email:string;full_name?:string|null;phone?:string|null;profile_photo?:string|null;role?:UserRole;target_university_id?:string|null;target_program_id?:string|null}>;
    universities: Table<Audit & {id:string;name:string;short_name:string|null;slug:string|null;description:string|null;location:string|null;website_url:string|null;logo_url:string|null;status:ContentStatus;sector:"public"|"private"|null;entry_test_name:string|null;application_status:string|null;introduction:string|null;campuses:string[];eligibility_criteria:string|null;entry_test_format:string|null;subject_distribution:Record<string,number>;negative_marking:string|null;test_duration:string|null;merit_formula:string|null;fee_information:string|null;important_dates:Record<string,string>;application_procedure:string[];application_url:string|null;last_verified_at:string|null}>;
    programs: Table<Audit & {id:string;university_id:string|null;name:string;slug:string;description:string|null;status:ContentStatus;icon:string|null;overview:string|null;eligibility_criteria:string|null;degree_options:string[];required_subjects:string[];entry_tests:string[];syllabus:string[];subject_weightage:Record<string,number>;preparation_duration:string|null;preparation_plan:string[]}>;
    program_universities: Table<{program_id:string;university_id:string;created_at:string}>;
    program_mock_tests: Table<{program_id:string;mock_test_id:string;created_at:string}>;
    entry_tests: Table<Audit & {id:string;name:string;slug:string;short_name:string|null;overview:string|null;who_should_take:string|null;eligibility:string|null;syllabus:string[];paper_pattern:string|null;subject_weightage:Record<string,number>;total_questions:number|null;total_marks:number|null;duration_minutes:number|null;negative_marking:string|null;difficulty_level:string|null;preparation_weeks:number|null;preparation_schedule:string[];official_url:string|null;status:ContentStatus;last_verified_at:string|null}>;
    entry_test_universities: Table<{entry_test_id:string;university_id:string;created_at:string}>;
    entry_test_programs: Table<{entry_test_id:string;program_id:string;created_at:string}>;
    entry_test_mock_tests: Table<{entry_test_id:string;mock_test_id:string;resource_type:"topic_test"|"full_mock"|"past_paper";created_at:string}>;
    subjects: Table<Audit & {id:string;name:string;slug:string;description:string|null;icon:string|null;display_order:number;status:ContentStatus;overview:string|null;important_formulas:string[]}>;
    chapters: Table<Audit & {id:string;subject_id:string;name:string;description:string|null;status:ContentStatus}>;
    topics: Table<Audit & {id:string;chapter_id:string;name:string;description:string|null;status:ContentStatus}>;
    study_materials: Table<Audit & {id:string;subject_id:string;chapter_id:string|null;topic_id:string|null;title:string;content:string;description:string|null;status:ContentStatus;resource_type:string;video_url:string|null;difficulty:QuestionDifficulty|null;estimated_minutes:number|null;access_tier:"free"|"premium";file_url:string|null;is_downloadable:boolean}>;
    study_material_universities: Table<{material_id:string;university_id:string;created_at:string}>;
    study_material_programs: Table<{material_id:string;program_id:string;created_at:string}>;
    study_material_entry_tests: Table<{material_id:string;entry_test_id:string;created_at:string}>;
    study_material_progress: Table<Audit & {student_id:string;material_id:string;completed:boolean;completed_at:string|null;last_viewed_at:string}>;
    questions: Table<Audit & {id:string;subject_id:string;chapter_id:string|null;topic_id:string|null;question_text:string;option_a:string;option_b:string;option_c:string;option_d:string;correct_answer:AnswerOption;explanation:string|null;difficulty:QuestionDifficulty;source:string|null;status:ContentStatus}>;
    exam_blueprints: Table<Audit & {id:string;university_id:string|null;program_id:string|null;name:string;description:string|null;version:number;status:ContentStatus}>;
    exam_blueprint_sections: Table<Audit & {id:string;blueprint_id:string;subject_id:string;name:string;question_count:number;section_order:number;question_filters:Record<string,unknown>}>;
    mock_tests: Table<Audit & {id:string;name:string;description:string|null;cover_image_url:string|null;question_count:number;duration_minutes:number;passing_percentage:number;status:ContentStatus;assessment_type:AssessmentType;blueprint_id:string|null}>;
    mock_test_questions: Table<{id:string;mock_test_id:string;question_id:string;question_order:number;created_at:string}>;
    exam_attempts: Table<{id:string;student_id:string;mock_test_id:string;started_at:string;submitted_at:string|null;status:AttemptStatus;total_questions:number;correct_answers:number;incorrect_answers:number;unanswered:number;score:number;percentage:number;time_used_seconds:number;created_at:string}>;
    attempt_answers: Table<{id:string;attempt_id:string;question_id:string;selected_answer:AnswerOption|null;is_correct:boolean|null;answered_at:string}>;
    student_progress: Table<{id:string;student_id:string;subject_id:string;topic_id:string|null;questions_attempted:number;questions_correct:number;average_score:number;updated_at:string}>;
    subscriptions: Table<Audit & {id:string;user_id:string;plan_name:string;status:SubscriptionStatus;starts_at:string;ends_at:string}>;
  };
  Views: Record<string, never>;
  Functions: {
    is_admin: { Args: Record<string, never>; Returns: boolean };
    start_mock_test: { Args:{p_mock_test_id:string}; Returns:Record<string,unknown> };
    submit_mock_test: { Args:{p_attempt_id:string;p_answers:unknown;p_time_used_seconds?:number}; Returns:Record<string,unknown> };
    save_attempt_answer: { Args:{p_attempt_id:string;p_question_id:string;p_selected_answer:AnswerOption}; Returns:Record<string,unknown> };
    has_active_subscription: { Args:{p_user_id?:string}; Returns:boolean };
    admin_grant_subscription: { Args:{p_email:string;p_days?:number;p_plan_name?:string}; Returns:string };
    list_study_material_catalog: { Args:Record<string,never>; Returns:Array<{id:string;subject_id:string;chapter_id:string|null;topic_id:string|null;title:string;description:string|null;resource_type:string;difficulty:QuestionDifficulty|null;estimated_minutes:number|null;access_tier:"free"|"premium";file_url:string|null;video_url:string|null;is_downloadable:boolean}> };
  };
  Enums: { user_role:"student"|"instructor"|"admin";content_status:ContentStatus;question_difficulty:QuestionDifficulty;answer_option:AnswerOption;exam_attempt_status:AttemptStatus;assessment_type:AssessmentType;subscription_status:SubscriptionStatus };
  CompositeTypes: Record<string, never>;
} };
