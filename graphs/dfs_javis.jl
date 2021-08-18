using Javis, Animations, Colors

function ground(args...)
    background("white")
    sethue("orange")
end

function make_circle(x, y, r, action=:stroke)
    circle(x, y, r, action)
    return Point(x, y)
end

function make_text(ftsize, str, pos=O, color="black", align=:center)
    sethue(color)
    fontsize(ftsize)
    text(str, pos, halign=align)
    return pos
end

function make_arrow(startpoint, endpoint, radius)
    sethue("black")
    x, y = get_direction_offset(startpoint, endpoint, radius)
    arrow(startpoint + Point(x, y), endpoint + Point(-x, -y))
    return startpoint
end

function get_direction_offset(a, b, r)
    xdiff = b.x - a.x
    ydiff = b.y - a.y

    sr = sqrt(2) / 2 * r
    offsets = [
        (sr, sr), (-sr, -sr), (sr, -sr), (-sr, sr), (0, r), (0, -r), (r, 0), (-r, 0)
    ]

    if ydiff > 0 && xdiff > 0 # right-down diagonal
        return offsets[1]
    elseif ydiff < 0 && xdiff < 0 # left-up diagonal
        return offsets[2]
    elseif ydiff < 0 && xdiff > 0 # right-up diagonal
        return offsets[3]
    elseif ydiff > 0 && xdiff < 0 # left-down diagonal
        return offsets[4]
    elseif ydiff > 0 # down
        return offsets[5]
    elseif ydiff < 0 # up
        return offsets[6]
    elseif xdiff > 0 # right
        return offsets[7]
    else # xdiff < 0 # left
        return offsets[8]
    end
end

function print_frontier(ds)
    if isempty(ds)
        return "[ ]"
    else
        return "$ds"
    end
end

const orange = (255, 165, 0) ./ 255
const blue = (0, 0, 255) ./ 255
const grey = (84, 84, 84) ./ 255

function dfs(gif::Bool=true)
    num_frames = 400
    radius = 40

    vertex_data = [
        (-300, -300, 1), (-300, 0, 2), (-300, 300, 3), (300, 300, 4), (300, -300, 5),
        (300, 0, 6), (0, 0, 7)
    ]
    edges = [
        (1, 2), (2, 3), (3, 4), (1, 7), (1, 5), (5, 7), (5, 6)
    ]
    V = length(vertex_data)
    E = length(edges)
    graph = [Vector{Tuple{Int, Int}}() for _ in 1:V]
    for e in edges
        u, v = e
        push!(graph[u], tuple(u, v))
    end

    video = Video(1000, 1000)
    Background(1:num_frames, ground)

    vertices = Object[]

    for vert in vertex_data
        x, y, v_no = vert
        circle_center = Object((args...) -> make_circle(x, y, radius, :fill))
        Object((args...) -> make_text(25, "$v_no", pos(circle_center) + Point(50, 35), "black"))
        push!(vertices, circle_center)
    end

    for edge in edges
        u, v = edge
        u_pos, v_pos = vertices[u], vertices[v]
        Object((args...) -> make_arrow(pos(u_pos), pos(v_pos), radius))
    end

    orange_to_blue = Animation(
        [0, 1],
        [RGB(orange...), RGB(blue...)],
        [sineio()],
    )

    blue_to_grey = Animation(
        [0, 1],
        [RGB(blue...), RGB(grey...)],
        [sineio()],
    )

    grey_to_blue = Animation(
        [0, 1],
        [RGB(grey...), RGB(blue...)],
        [sineio()],
    )

    fno = 30

    source = 1
    stack = Vector{Int}()
    visited = falses(length(graph))
    push!(stack, source)

    stack_text = Object((args...; text=print_frontier(stack)) -> 
        make_text(25, "Stack: $text", Point(0, -400), "black")
    )

    while !isempty(stack)
        v = pop!(stack)
        if !visited[v]
            visited[v] = true
            for edge in graph[v]
                push!(stack, edge[2])
            end
            act!(vertices[v], Action(fno:fno+15, orange_to_blue, sethue()))
            fno += 15
            act!(stack_text, Action(fno:fno+15, change(:text, print_frontier(stack))))
            fno += 15
            act!(vertices[v], Action(fno:fno+15, blue_to_grey, sethue()))
            fno += 15
        else
            act!(vertices[v], Action(fno:fno+15, grey_to_blue, sethue()))
            fno += 15
            act!(stack_text, Action(fno:fno+15, change(:text, print_frontier(stack))))
            fno += 15
            act!(vertices[v], Action(fno:fno+15, blue_to_grey, sethue()))
            fno += 15
        end
    end

    render(
        video;
        pathname = if gif "dfs.gif" else "dfs.mp4" end,
        framerate = 30
    )
    return fno
end

dfs()
dfs(false)
