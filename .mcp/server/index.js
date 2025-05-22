#!/usr/bin/env node

/**
 * AICheck MCP Server
 * 
 * This MCP server provides tools that integrate Claude with the AICheck governance system.
 * It allows Claude to interact with and enforce the rules defined in RULES.md.
 */

const fs = require('fs-extra');
const path = require('path');
const { glob } = require('glob');

// Find the root of the AICheck project
let projectRoot = process.cwd();
while (!fs.existsSync(path.join(projectRoot, '.aicheck')) && projectRoot !== '/') {
  projectRoot = path.dirname(projectRoot);
}

if (projectRoot === '/') {
  console.error('Could not find AICheck project root');
  process.exit(1);
}

console.log(`AICheck project root: ${projectRoot}`);

// MCP server configuration
const server = {
  capabilities: {
    name: 'aicheck-mcp',
    version: '0.1.0',
    description: 'AICheck governance system MCP server',
    resources: {
      'aicheck/rules': {
        type: 'text/markdown',
        description: 'The rules governing the AICheck system',
        usage: 'Read the AICheck rules to understand the governance system'
      },
      'aicheck/actions_index': {
        type: 'text/markdown',
        description: 'The index of all actions in the project',
        usage: 'Read the actions index to see all actions and their status'
      },
      'aicheck/current_action': {
        type: 'text/plain',
        description: 'The currently active action',
        usage: 'Read the current action to see what is being worked on'
      }
    },
    tools: {
      'aicheck.getCurrentAction': {
        name: 'aicheck.getCurrentAction',
        description: 'Get the currently active action',
        usage: 'Use this to check which action is currently active',
        parameters: {},
        returns: {
          type: 'object',
          properties: {
            action: {
              type: 'string',
              description: 'The name of the active action'
            },
            status: {
              type: 'string',
              description: 'The status of the active action'
            }
          }
        }
      },
      'aicheck.listActions': {
        name: 'aicheck.listActions',
        description: 'List all actions in the project',
        usage: 'Use this to get a list of all actions in the project',
        parameters: {
          status: {
            type: 'string',
            description: 'Filter actions by status (optional)',
            enum: ['Not Started', 'ActiveAction', 'Completed', 'Blocked', 'On Hold']
          }
        },
        returns: {
          type: 'array',
          items: {
            type: 'object',
            properties: {
              name: {
                type: 'string',
                description: 'The name of the action'
              },
              status: {
                type: 'string',
                description: 'The status of the action'
              },
              description: {
                type: 'string',
                description: 'A brief description of the action'
              }
            }
          }
        }
      },
      'aicheck.getActionPlan': {
        name: 'aicheck.getActionPlan',
        description: 'Get the plan for a specific action',
        usage: 'Use this to read the plan for an action',
        parameters: {
          action: {
            type: 'string',
            description: 'The name of the action'
          }
        },
        returns: {
          type: 'object',
          properties: {
            content: {
              type: 'string',
              description: 'The content of the action plan'
            },
            exists: {
              type: 'boolean',
              description: 'Whether the action plan exists'
            }
          }
        }
      },
      'aicheck.createActionDirectory': {
        name: 'aicheck.createActionDirectory',
        description: 'Create a new action directory with the required structure',
        usage: 'Use this to create a new action',
        parameters: {
          action: {
            type: 'string',
            description: 'The name of the action'
          }
        },
        returns: {
          type: 'object',
          properties: {
            success: {
              type: 'boolean',
              description: 'Whether the action directory was created successfully'
            },
            path: {
              type: 'string',
              description: 'The path to the created action directory'
            }
          }
        }
      },
      'aicheck.writeActionPlan': {
        name: 'aicheck.writeActionPlan',
        description: 'Write an action plan (requires human approval)',
        usage: 'Use this to create or update an action plan',
        parameters: {
          action: {
            type: 'string',
            description: 'The name of the action'
          },
          content: {
            type: 'string',
            description: 'The content of the action plan'
          }
        },
        returns: {
          type: 'object',
          properties: {
            success: {
              type: 'boolean',
              description: 'Whether the action plan was written successfully'
            },
            message: {
              type: 'string',
              description: 'A message describing the result'
            },
            requiresApproval: {
              type: 'boolean',
              description: 'Whether the action plan requires human approval'
            }
          }
        }
      },
      'aicheck.setCurrentAction': {
        name: 'aicheck.setCurrentAction',
        description: 'Set the currently active action (requires human approval)',
        usage: 'Use this to change the active action',
        parameters: {
          action: {
            type: 'string',
            description: 'The name of the action to set as active'
          }
        },
        returns: {
          type: 'object',
          properties: {
            success: {
              type: 'boolean',
              description: 'Whether the active action was set successfully'
            },
            message: {
              type: 'string',
              description: 'A message describing the result'
            },
            requiresApproval: {
              type: 'boolean',
              description: 'Whether setting the active action requires human approval'
            }
          }
        }
      },
      'aicheck.logClaudeInteraction': {
        name: 'aicheck.logClaudeInteraction',
        description: 'Log a Claude interaction for the current action',
        usage: 'Use this to log Claude interactions as required by RULES.md',
        parameters: {
          purpose: {
            type: 'string',
            description: 'The purpose of the interaction'
          },
          prompt: {
            type: 'string',
            description: 'The prompt used for the interaction'
          },
          response: {
            type: 'string',
            description: 'Claude\'s response'
          },
          modifications: {
            type: 'string',
            description: 'Any modifications made (optional)'
          },
          verification: {
            type: 'string',
            description: 'How the output was verified (optional)'
          }
        },
        returns: {
          type: 'object',
          properties: {
            success: {
              type: 'boolean',
              description: 'Whether the interaction was logged successfully'
            },
            path: {
              type: 'string',
              description: 'The path to the interaction log file'
            }
          }
        }
      }
    }
  }
};

// Implementation of resource providers
const resourceProviders = {
  'aicheck/rules': async () => {
    try {
      return await fs.readFile(path.join(projectRoot, '.aicheck', 'rules.md'), 'utf8');
    } catch (error) {
      console.error('Error reading rules:', error);
      return 'Error: Rules not found';
    }
  },
  'aicheck/actions_index': async () => {
    try {
      return await fs.readFile(path.join(projectRoot, '.aicheck', 'actions_index.md'), 'utf8');
    } catch (error) {
      console.error('Error reading actions index:', error);
      return 'Error: Actions index not found';
    }
  },
  'aicheck/current_action': async () => {
    try {
      return await fs.readFile(path.join(projectRoot, '.aicheck', 'current_action'), 'utf8');
    } catch (error) {
      console.error('Error reading current action:', error);
      return 'Error: Current action not found';
    }
  }
};

// Implementation of tool handlers
const toolHandlers = {
  'aicheck.getCurrentAction': async () => {
    try {
      const currentAction = await fs.readFile(path.join(projectRoot, '.aicheck', 'current_action'), 'utf8');
      return {
        action: currentAction.trim(),
        status: 'Unknown' // In a full implementation, we would parse the status from the action directory
      };
    } catch (error) {
      console.error('Error getting current action:', error);
      return {
        action: 'None',
        status: 'None'
      };
    }
  },
  'aicheck.listActions': async (params) => {
    try {
      const actionsDir = path.join(projectRoot, '.aicheck', 'actions');
      if (!fs.existsSync(actionsDir)) {
        return [];
      }
      
      const actionDirs = await fs.readdir(actionsDir);
      const actions = [];
      
      for (const dir of actionDirs) {
        const actionDir = path.join(actionsDir, dir);
        const stats = await fs.stat(actionDir);
        
        if (!stats.isDirectory()) {
          continue;
        }
        
        const statusPath = path.join(actionDir, 'status.txt');
        let status = 'Unknown';
        
        if (fs.existsSync(statusPath)) {
          status = (await fs.readFile(statusPath, 'utf8')).trim();
        }
        
        if (params.status && status !== params.status) {
          continue;
        }
        
        const planPath = path.join(actionDir, `${dir}-plan.md`);
        let description = 'No description available';
        
        if (fs.existsSync(planPath)) {
          const planContent = await fs.readFile(planPath, 'utf8');
          const descriptionMatch = planContent.match(/## Description\s+(.*?)(?=\s+##|$)/s);
          if (descriptionMatch) {
            description = descriptionMatch[1].trim();
          }
        }
        
        actions.push({
          name: dir,
          status,
          description
        });
      }
      
      return actions;
    } catch (error) {
      console.error('Error listing actions:', error);
      return [];
    }
  },
  'aicheck.getActionPlan': async (params) => {
    try {
      const planPath = path.join(projectRoot, '.aicheck', 'actions', params.action, `${params.action}-plan.md`);
      
      if (!fs.existsSync(planPath)) {
        return {
          content: '',
          exists: false
        };
      }
      
      const content = await fs.readFile(planPath, 'utf8');
      
      return {
        content,
        exists: true
      };
    } catch (error) {
      console.error('Error getting action plan:', error);
      return {
        content: '',
        exists: false
      };
    }
  },
  'aicheck.createActionDirectory': async (params) => {
    try {
      const actionDir = path.join(projectRoot, '.aicheck', 'actions', params.action);
      
      if (fs.existsSync(actionDir)) {
        return {
          success: false,
          path: actionDir,
          message: 'Action directory already exists'
        };
      }
      
      await fs.mkdirp(actionDir);
      await fs.mkdirp(path.join(actionDir, 'supporting_docs'));
      await fs.mkdirp(path.join(actionDir, 'supporting_docs', 'claude-interactions'));
      await fs.mkdirp(path.join(actionDir, 'supporting_docs', 'process-tests'));
      await fs.mkdirp(path.join(actionDir, 'supporting_docs', 'research'));
      await fs.mkdirp(path.join(actionDir, 'supporting_docs', 'diagrams'));
      
      await fs.writeFile(path.join(actionDir, 'status.txt'), 'Not Started');
      await fs.writeFile(path.join(actionDir, 'progress.md'), `# ${params.action} Progress\n\nProgress: 0%\n`);
      
      return {
        success: true,
        path: actionDir
      };
    } catch (error) {
      console.error('Error creating action directory:', error);
      return {
        success: false,
        path: '',
        message: `Error: ${error.message}`
      };
    }
  },
  'aicheck.writeActionPlan': async (params) => {
    // In a real implementation, this would require human approval
    // For now, we'll just note that approval is required
    try {
      const actionDir = path.join(projectRoot, '.aicheck', 'actions', params.action);
      
      if (!fs.existsSync(actionDir)) {
        await toolHandlers['aicheck.createActionDirectory']({ action: params.action });
      }
      
      const planPath = path.join(actionDir, `${params.action}-plan.md`);
      
      await fs.writeFile(planPath, params.content);
      
      return {
        success: true,
        message: 'Action plan written successfully, but requires human approval',
        requiresApproval: true
      };
    } catch (error) {
      console.error('Error writing action plan:', error);
      return {
        success: false,
        message: `Error: ${error.message}`,
        requiresApproval: true
      };
    }
  },
  'aicheck.setCurrentAction': async (params) => {
    // In a real implementation, this would require human approval
    // For now, we'll just note that approval is required
    try {
      const actionDir = path.join(projectRoot, '.aicheck', 'actions', params.action);
      
      if (!fs.existsSync(actionDir)) {
        return {
          success: false,
          message: 'Action does not exist',
          requiresApproval: true
        };
      }
      
      await fs.writeFile(path.join(projectRoot, '.aicheck', 'current_action'), params.action);
      
      return {
        success: true,
        message: 'Current action set successfully, but requires human approval',
        requiresApproval: true
      };
    } catch (error) {
      console.error('Error setting current action:', error);
      return {
        success: false,
        message: `Error: ${error.message}`,
        requiresApproval: true
      };
    }
  },
  'aicheck.logClaudeInteraction': async (params) => {
    try {
      const currentAction = (await fs.readFile(path.join(projectRoot, '.aicheck', 'current_action'), 'utf8')).trim();
      
      if (!currentAction || currentAction === 'No active action currently assigned.') {
        return {
          success: false,
          path: '',
          message: 'No active action set'
        };
      }
      
      const interactionsDir = path.join(
        projectRoot, 
        '.aicheck', 
        'actions', 
        currentAction, 
        'supporting_docs', 
        'claude-interactions'
      );
      
      if (!fs.existsSync(interactionsDir)) {
        await fs.mkdirp(interactionsDir);
      }
      
      const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
      const logPath = path.join(interactionsDir, `interaction-${timestamp}.md`);
      
      const logContent = `# Claude Interaction Log

**Date**: ${new Date().toISOString().split('T')[0]}
**ACTION**: ${currentAction}
**Purpose**: ${params.purpose}
**Template Used**: custom
**Prompt Hash**: ${Buffer.from(params.prompt).toString('base64').substr(0, 8)}

## Prompt

${params.prompt}

## Response

${params.response}

## Modifications

${params.modifications || 'None'}

## Verification

${params.verification || 'None'}

## Iterations

[Number of attempts: 1]
`;
      
      await fs.writeFile(logPath, logContent);
      
      return {
        success: true,
        path: logPath
      };
    } catch (error) {
      console.error('Error logging Claude interaction:', error);
      return {
        success: false,
        path: '',
        message: `Error: ${error.message}`
      };
    }
  }
};

// MCP message handling
process.stdin.setEncoding('utf8');
let buffer = '';

process.stdin.on('data', (chunk) => {
  buffer += chunk;
  
  // Process complete messages
  let newlineIndex;
  while ((newlineIndex = buffer.indexOf('\n')) !== -1) {
    const message = buffer.slice(0, newlineIndex);
    buffer = buffer.slice(newlineIndex + 1);
    
    handleMessage(message);
  }
});

async function handleMessage(message) {
  try {
    const parsedMessage = JSON.parse(message);
    
    if (!parsedMessage.jsonrpc || parsedMessage.jsonrpc !== '2.0') {
      sendErrorResponse(parsedMessage.id, -32600, 'Invalid Request');
      return;
    }
    
    if (parsedMessage.method === 'getCapabilities') {
      sendResponse(parsedMessage.id, server.capabilities);
      return;
    }
    
    if (parsedMessage.method === 'getResource') {
      const resourceName = parsedMessage.params.name;
      
      if (!resourceProviders[resourceName]) {
        sendErrorResponse(parsedMessage.id, -32602, `Resource not found: ${resourceName}`);
        return;
      }
      
      try {
        const content = await resourceProviders[resourceName]();
        sendResponse(parsedMessage.id, { content });
      } catch (error) {
        sendErrorResponse(parsedMessage.id, -32603, `Error getting resource: ${error.message}`);
      }
      
      return;
    }
    
    if (parsedMessage.method === 'runTool') {
      const toolName = parsedMessage.params.name;
      const toolParams = parsedMessage.params.parameters || {};
      
      if (!toolHandlers[toolName]) {
        sendErrorResponse(parsedMessage.id, -32602, `Tool not found: ${toolName}`);
        return;
      }
      
      try {
        const result = await toolHandlers[toolName](toolParams);
        sendResponse(parsedMessage.id, { result });
      } catch (error) {
        sendErrorResponse(parsedMessage.id, -32603, `Error running tool: ${error.message}`);
      }
      
      return;
    }
    
    sendErrorResponse(parsedMessage.id, -32601, `Method not found: ${parsedMessage.method}`);
  } catch (error) {
    console.error('Error handling message:', error);
    
    try {
      const parsedMessage = JSON.parse(message);
      sendErrorResponse(parsedMessage.id, -32700, `Parse error: ${error.message}`);
    } catch {
      // Can't parse the message to get an ID, so we can't send a proper error response
      console.error('Cannot parse message to send error response');
    }
  }
}

function sendResponse(id, result) {
  const response = {
    jsonrpc: '2.0',
    id,
    result
  };
  
  process.stdout.write(JSON.stringify(response) + '\n');
}

function sendErrorResponse(id, code, message) {
  const response = {
    jsonrpc: '2.0',
    id,
    error: {
      code,
      message
    }
  };
  
  process.stdout.write(JSON.stringify(response) + '\n');
}

console.log('AICheck MCP server started');