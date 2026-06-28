local starter = require('mini.starter')

local frog = [[
                       ,-.
                  _,-' - `--._
                ,'.:  __' _..-)
              ,'     /,o)'  ,'
             ;.    ,'`-' _,)
           ,'   :.   _.-','
         ,' .  .    (   /
        ; .:'     .. `-/
      ,'       ;     ,'
   _,/ .   ,      .,' ,
 ,','     .  .  . .\,'..__
,','  .:.      ' ,\ `\)``
`-\_..---``````-'-.`.:`._/
,'   '` .` ,`- -.  ) `--..`-..
`-...__________..-'-.._  \
   ``--------..`-._ ```
               ``    ]]

local neovim_text = [[
 ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
 ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
 ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
 ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
 ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
 ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]]

local function side_by_side(left_art, right_art, gap)
  gap = gap or 6
  local left_lines = vim.split(left_art, '\n')
  local right_lines = vim.split(right_art, '\n')

  local left_width = 0
  for _, line in ipairs(left_lines) do
    left_width = math.max(left_width, vim.fn.strdisplaywidth(line))
  end

  local n_left, n_right = #left_lines, #right_lines
  local max_lines = math.max(n_left, n_right)
  local left_offset = math.floor((max_lines - n_left) / 2)
  local right_offset = math.floor((max_lines - n_right) / 2)

  local result = {}
  for i = 1, max_lines do
    local li, ri = i - left_offset, i - right_offset
    local left = (li >= 1 and li <= n_left) and left_lines[li] or ''
    local right = (ri >= 1 and ri <= n_right) and right_lines[ri] or ''
    local pad = left_width - vim.fn.strdisplaywidth(left) + gap
    table.insert(result, left .. string.rep(' ', pad) .. right)
  end

  return table.concat(result, '\n')
end

vim.api.nvim_create_autocmd('ColorScheme', {
  callback = function()
    vim.api.nvim_set_hl(0, 'MiniStarterHeader', { fg = '#fabd2f' })
  end,
})

-- Collect top-level project roots under ~/Code: any dir containing a
-- CMakeLists.txt or .git, with nested sub-projects folded into their parent.
local function project_roots()
  local base = vim.fn.expand('~/Code')
  if vim.fn.executable('fd') ~= 1 then return {} end

  local roots, seen = {}, {}
  local function collect(args)
    for _, marker in ipairs(vim.fn.systemlist(args)) do
      local dir = vim.fn.fnamemodify(marker, ':h')
      if not seen[dir] then
        seen[dir] = true
        table.insert(roots, dir)
      end
    end
  end
  collect { 'fd', '--type', 'f', '--max-depth', '6', '--glob', 'CMakeLists.txt', base }
  collect { 'fd', '--hidden', '--no-ignore', '--type', 'd', '--max-depth', '6', '--glob', '.git', base }

  table.sort(roots) -- parents sort before their children
  local top = {}
  for _, r in ipairs(roots) do
    local nested = false
    for _, t in ipairs(top) do
      if r:sub(1, #t + 1) == t .. '/' then nested = true break end
    end
    if not nested then table.insert(top, r) end
  end
  return top
end

-- Telescope picker over project roots: select one to cd in and find files.
local function pick_project()
  local roots = project_roots()
  if #roots == 0 then
    vim.notify('No projects found under ~/Code (is fd installed?)', vim.log.levels.WARN)
    return
  end

  local pickers       = require('telescope.pickers')
  local finders       = require('telescope.finders')
  local conf          = require('telescope.config').values
  local actions       = require('telescope.actions')
  local action_state  = require('telescope.actions.state')
  local home          = vim.fn.expand('~')

  pickers.new({}, {
    prompt_title = 'Projects',
    finder = finders.new_table {
      results = roots,
      entry_maker = function(path)
        local display = path:gsub('^' .. vim.pesc(home), '~')
        return { value = path, display = display, ordinal = display }
      end,
    },
    sorter = conf.generic_sorter {},
    attach_mappings = function(bufnr)
      actions.select_default:replace(function()
        local entry = action_state.get_selected_entry()
        actions.close(bufnr)
        if entry then
          vim.cmd.cd(vim.fn.fnameescape(entry.value))
          require('telescope.builtin').find_files()
        end
      end)
      return true
    end,
  }):find()
end

vim.keymap.set('n', '<leader>sp', pick_project, { desc = '[S]earch [P]rojects' })

-- ----------------------------------------------------------------------------
-- Create a new project: prompt for name / location / template, scaffold the
-- folders + files, git init, then cd in and open the entry file.
-- ----------------------------------------------------------------------------

-- Write `contents` to `path`, creating parent directories as needed.
local function write_file(path, contents)
  vim.fn.mkdir(vim.fn.fnamemodify(path, ':h'), 'p')
  local fd, err = io.open(path, 'w')
  if not fd then
    vim.notify('Could not write ' .. path .. ': ' .. (err or '?'), vim.log.levels.ERROR)
    return false
  end
  fd:write(contents)
  fd:close()
  return true
end

-- Templates. Each returns the file it should open after scaffolding, or nil.
local templates = {
  ['C++ (CMake)'] = function(root, name)
    local target = name:gsub('[^%w_]', '_') -- valid CMake target / executable name
    write_file(root .. '/CMakeLists.txt', ([[
cmake_minimum_required(VERSION 3.20)
project(%s CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_executable(%s src/main.cpp)
]]):format(target, target))
    write_file(root .. '/src/main.cpp', ([[
#include <iostream>

int main() {
    std::cout << "Hello, %s!\n";
    return 0;
}
]]):format(name))
    write_file(root .. '/.gitignore', '/build/\n/out/\ncompile_commands.json\n')
    return root .. '/src/main.cpp'
  end,

  ['OpenGL (GLFW, macOS)'] = function(root, name)
    local target = name:gsub('[^%w_]', '_')
    -- GLFW is fetched at configure time (needs network on first :CMakeGenerate).
    -- Uses Apple's native <OpenGL/gl3.h> (GL 3.2-4.1 core), so no extension
    -- loader (glad/glew) and no Python codegen is required.
    write_file(root .. '/CMakeLists.txt', ([=[
cmake_minimum_required(VERSION 3.20)
project(%s C CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

include(FetchContent)

set(GLFW_BUILD_DOCS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
FetchContent_Declare(glfw
    GIT_REPOSITORY https://github.com/glfw/glfw
    GIT_TAG 3.4)
FetchContent_MakeAvailable(glfw)

find_package(OpenGL REQUIRED)

add_executable(%s src/main.cpp)
target_link_libraries(%s PRIVATE glfw OpenGL::GL)
# Lets main.cpp load shaders by absolute path regardless of the run cwd.
target_compile_definitions(%s PRIVATE SHADER_DIR="${CMAKE_CURRENT_SOURCE_DIR}/shaders")
]=]):format(target, target, target, target))

    write_file(root .. '/src/main.cpp', ([=[
#define GL_SILENCE_DEPRECATION
#include <OpenGL/gl3.h>
#include <GLFW/glfw3.h>

#include <fstream>
#include <iostream>
#include <sstream>
#include <string>

static std::string read_file(const char *path) {
    std::ifstream f(path);
    if (!f) {
        std::cerr << "Failed to open " << path << '\n';
        return {};
    }
    std::stringstream ss;
    ss << f.rdbuf();
    return ss.str();
}

static GLuint compile(GLenum type, const std::string &src) {
    GLuint sh = glCreateShader(type);
    const char *c = src.c_str();
    glShaderSource(sh, 1, &c, nullptr);
    glCompileShader(sh);
    GLint ok = 0;
    glGetShaderiv(sh, GL_COMPILE_STATUS, &ok);
    if (!ok) {
        char log[512];
        glGetShaderInfoLog(sh, sizeof(log), nullptr, log);
        std::cerr << "Shader compile error: " << log << '\n';
    }
    return sh;
}

int main() {
    if (!glfwInit()) {
        std::cerr << "glfwInit failed\n";
        return 1;
    }
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE); // required for core profile on macOS

    GLFWwindow *win = glfwCreateWindow(800, 600, "%s", nullptr, nullptr);
    if (!win) {
        std::cerr << "Failed to create window\n";
        glfwTerminate();
        return 1;
    }
    glfwMakeContextCurrent(win);

    GLuint vs = compile(GL_VERTEX_SHADER, read_file(SHADER_DIR "/triangle.vert"));
    GLuint fs = compile(GL_FRAGMENT_SHADER, read_file(SHADER_DIR "/triangle.frag"));
    GLuint prog = glCreateProgram();
    glAttachShader(prog, vs);
    glAttachShader(prog, fs);
    glLinkProgram(prog);
    glDeleteShader(vs);
    glDeleteShader(fs);

    float verts[] = {
        -0.5f, -0.5f, 0.0f,
         0.5f, -0.5f, 0.0f,
         0.0f,  0.5f, 0.0f,
    };
    GLuint vao = 0, vbo = 0;
    glGenVertexArrays(1, &vao);
    glGenBuffers(1, &vbo);
    glBindVertexArray(vao);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(verts), verts, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void *)0);
    glEnableVertexAttribArray(0);

    while (!glfwWindowShouldClose(win)) {
        if (glfwGetKey(win, GLFW_KEY_ESCAPE) == GLFW_PRESS)
            glfwSetWindowShouldClose(win, GLFW_TRUE);

        glClearColor(0.1f, 0.1f, 0.12f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        glUseProgram(prog);
        glBindVertexArray(vao);
        glDrawArrays(GL_TRIANGLES, 0, 3);

        glfwSwapBuffers(win);
        glfwPollEvents();
    }

    glfwTerminate();
    return 0;
}
]=]):format(name))

    write_file(root .. '/shaders/triangle.vert', [=[
#version 330 core
layout (location = 0) in vec3 aPos;

void main() {
    gl_Position = vec4(aPos, 1.0);
}
]=])
    write_file(root .. '/shaders/triangle.frag', [=[
#version 330 core
out vec4 FragColor;

void main() {
    FragColor = vec4(1.0, 0.5, 0.2, 1.0);
}
]=])
    write_file(root .. '/.gitignore', '/build/\n/out/\ncompile_commands.json\n')
    return root .. '/src/main.cpp'
  end,

  ['Empty folder'] = function(root)
    vim.fn.mkdir(root, 'p')
    return nil
  end,
}

local function create_project()
  vim.ui.input({ prompt = 'Project name: ' }, function(name)
    if not name or vim.trim(name) == '' then return end
    name = vim.trim(name)

    vim.ui.input({ prompt = 'Parent directory: ', default = vim.fn.expand('~/Code'), completion = 'dir' }, function(parent)
      if not parent or parent == '' then return end
      local root = vim.fn.expand(parent) .. '/' .. name

      if vim.fn.isdirectory(root) == 1 and #vim.fn.readdir(root) > 0 then
        vim.notify(root .. ' already exists and is not empty', vim.log.levels.ERROR)
        return
      end

      vim.ui.select(vim.tbl_keys(templates), { prompt = 'Template for ' .. name .. ':' }, function(choice)
        if not choice then return end

        vim.fn.mkdir(root, 'p')
        local open_target = templates[choice](root, name)
        vim.fn.system { 'git', '-C', root, 'init', '-q' }

        vim.cmd.cd(vim.fn.fnameescape(root))
        if open_target then
          vim.cmd.edit(vim.fn.fnameescape(open_target))
        else
          require('telescope.builtin').find_files()
        end
        vim.notify('Created ' .. choice .. ' project at ' .. root)
      end)
    end)
  end)
end

vim.keymap.set('n', '<leader>np', create_project, { desc = '[N]ew [P]roject' })

starter.setup {
  header = side_by_side(frog, neovim_text),
  items = {
    { name = 'New project',           action = create_project,                                      section = '' },
    { name = 'Projects',              action = pick_project,                                        section = '' },
    { name = 'Find file',             action = 'Telescope find_files',                              section = '' },
    { name = 'Edit new file',         action = 'enew',                                              section = '' },
    { name = 'Configuration',         action = 'edit ' .. vim.fn.stdpath('config') .. '/init.lua', section = '' },
    { name = 'Update plugins',        action = 'lua vim.pack.update()',                             section = '' },
    { name = 'Recently opened files', action = 'Telescope oldfiles',                                section = '' },
    { name = 'Quit',                  action = 'qa',                                                section = '' },
  },
  footer = 'The universe is all a spin-off of the Big Bang.',
  content_hooks = {
    starter.gen_hook.adding_bullet('  '),
    starter.gen_hook.aligning('center', 'center'),
  },
}
