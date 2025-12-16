package tools

// AvailableTool defines a simple tool metadata used by settings APIs.
type AvailableTool struct {
	Name        string `json:"name"`
	Label       string `json:"label"`
	Description string `json:"description"`
}

// AvailableToolDefinitions returns the list of tools exposed to the UI.
// Keep this in sync with registered tools in this package.
func AvailableToolDefinitions() []AvailableTool {
	return []AvailableTool{
		{Name: "thinking", Label: "Thinking", Description: "Dynamic and reflective problem-solving thinking tool"},
		{Name: "todo_write", Label: "Formulate Plan", Description: "Create structured research plans"},
		{Name: "grep_chunks", Label: "Keyword Search", Description: "Quickly locate documents and chunks containing specific keywords"},
		{Name: "knowledge_search", Label: "Semantic Search", Description: "Understand problems and find semantically relevant content"},
		{Name: "list_knowledge_chunks", Label: "View Document Chunks", Description: "Obtain complete document chunk content"},
		{Name: "query_knowledge_graph", Label: "Query Knowledge Graph", Description: "Query relationships from the knowledge graph"},
		{Name: "get_document_info", Label: "Get Document Information", Description: "View document metadata"},
		{Name: "database_query", Label: "Query Database", Description: "Query information in the database"},
	}
}

// DefaultAllowedTools returns the default allowed tools list.
func DefaultAllowedTools() []string {
	return []string{
		"thinking",
		"todo_write",
		"knowledge_search",
		"grep_chunks",
		"list_knowledge_chunks",
		"query_knowledge_graph",
		"get_document_info",
		"database_query",
	}
}
