---
applyTo: '**'
---
Provide project context and coding guidelines that AI should follow when generating code, answering questions, or reviewing changes.
Do not create any .md files unless explicitly asked to.
Do not add emojis in code comments or documentation unless explicitly asked to.
All comments should be clear, concise, and in lowercase.
Use consistent naming conventions for variables, functions, classes, and files (e.g., camelCase for variables and functions, PascalCase for classes).
When generating code, ensure it is well-structured, follows best practices, and is free of syntax errors.
When reviewing changes, focus on code quality, readability, maintainability, and adherence to the project's coding standards.
When answering questions or generating answers or code, do not include any emojis in the responses unless explicitly asked to.
When creating screens: Match the Figma/UI designs you provide as closely as possible.
Reusability: Create shared utilities instead of duplicating code across screens.
The functions and methods in the utils folder, always use them for their appropriate usecases.
Use the utils, widgets already implemented and follow the ui design accurately.
Follow the design and the components positions strictly, check out previous on how the layout is done.
Show your implementation plan.
In every remote datasource method, add dev.log calls using dart:developer with name: 'API' in this exact format:
  log('{endpoint_name} url: $url', name: 'API');
  log('{endpoint_name} body: ${jsonEncode(body)}', name: 'API');
  log('{endpoint_name} response: ${jsonEncode(responseBody)}', name: 'API');
where {endpoint_name} is a short snake_case label for the operation (e.g. login_email, get_products).

