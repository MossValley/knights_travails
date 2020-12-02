#frozen_string_literal: true
require 'pry'

class MovementNode
    attr_accessor :data, :moveset, :moveset_names, :parent

    def initialize(coordinates, moveset_names, parent=nil)
        @data = coordinates
        @moveset = []
        @moveset_names = moveset_names
        @parent = parent
    end
end

class KnightMoves
    attr_reader  :root_pos

    def initialize(move_arr)
        @range = (0...8).to_a
        @game_board = generate_board
        input_checker(move_arr)
        @start_pos = move_arr[0]
        @end_pos = move_arr[1]

        @root_pos = build_moveset_tree(@start_pos)
    end 
    
    def root_output(root=@root_pos)
        node_path = pathfinder
        puts "KnightMoves(#{@start_pos}, #{@end_pos})"
        puts "You made it in #{node_path.length-1} #{ node_path.length-1 > 1 ? "moves" : "move"}! Here is your path:"
        node_path.each { |node| p node }
    end

    def show_board
        @range.each { |i| p @game_board[i] }
    end

    private

    def input_checker(coordinates)
        coordinates.each do |position|
            if !@game_board.flatten(1).include? position
                abort("Error! Positions outside of board!")
            end
        end
    end

    def generate_board
        board_len = @range
        board = []
        board_len.each do |row|
            board_row = []
            board_len.each do |col|
                board_row << [row, col]
            end
            board << board_row
        end
        board
    end

    def build_moveset_tree(node) #builds tree in a level-order sort manner to minimise path lenght to any paricular node
        board = @game_board.flatten(1)
        root = MovementNode.new(node, list_moveset(node, board))
        
        queue = [root] 
        until queue.empty?
            root_down = queue.shift
            root_down.moveset_names.each do |move_node|
                new_node = MovementNode.new(move_node, list_moveset(move_node, board), root_down)
                root_down.moveset << new_node
                queue << new_node
            end
        end
        root
    end

    def list_moveset(node, board_grid) #maps L-shape movement options in two parts: long part of L, short part of L
        board_grid.delete(node)
        co_0 = node[0]
        co_1 = node[1]
        moves = []

        #co_0 is long part of L
        if @range.include? (co_0 + 2) #up
            moves << board_grid.delete([co_0 + 2, co_1 +1]) if @range.include? (co_1 + 1) #up_right
            moves << board_grid.delete([co_0 + 2, co_1 -1]) if @range.include? (co_1 - 1) #up_left
        end
        if @range.include? (co_0 - 2) #down
            moves << board_grid.delete([co_0 - 2, co_1 +1]) if @range.include? (co_1 + 1) #down_right
            moves << board_grid.delete([co_0 - 2, co_1 -1]) if @range.include? (co_1 - 1) #down_left
        end

        #co_1 is long part of L
        if @range.include? (co_1 + 2) #right
            moves << board_grid.delete([co_0 +1, co_1 + 2]) if @range.include? (co_0 + 1) #right_up
            moves << board_grid.delete([co_0 -1, co_1 + 2] )if @range.include? (co_0 - 1) #right_down
        end
        if @range.include? (co_1 - 2) #left
            moves << board_grid.delete([co_0 +1, co_1 - 2]) if @range.include? (co_0 + 1) #left_up
            moves << board_grid.delete([co_0 -1, co_1 - 2]) if @range.include? (co_0 - 1) #left_down
        end

        moves.delete(nil)
        return moves
    end

    def pathfinder
        queue = [@root_pos]
        path = []

        until queue.empty?
            next_node = queue.shift
            next_node.moveset.each { |move| queue << move }
            path = find_end(next_node)
            queue = [] unless path.nil?
        end
        path.nil? ? [@root_pos.data] : path
    end

    def find_end(node, end_node=nil)
        return if node.nil?

        node.moveset.each do |next_node|
            end_node = next_node if next_node.data == @end_pos
            break unless end_node.nil?
            find_end(next_node, end_node)
        end
        end_node.nil? ? nil : path_tracer(end_node)
    end

    def path_tracer(node, path_array=[node.data])
        return if node.parent.nil?

        path_array.unshift(node.parent.data)
        path_tracer(node.parent, path_array)

        path_array
    end
end

board = KnightMoves.new([[3,3],[4,3]])
board.root_output
