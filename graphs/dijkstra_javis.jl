using Javis, Animations, Colors, DataStructures

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
    return (startpoint + endpoint) / 2
end

function get_direction_index(xdiff, ydiff)
    if ydiff > 0 && xdiff > 0 # right-down diagonal
        return 1
    elseif ydiff < 0 && xdiff < 0 # left-up diagonal
        return 2
    elseif ydiff < 0 && xdiff > 0 # right-up diagonal
        return 3
    elseif ydiff > 0 && xdiff < 0 # left-down diagonal
        return 4
    elseif ydiff > 0 # down
        return 5
    elseif ydiff < 0 # up
        return 6
    elseif xdiff > 0 # right
        return 7
    else # xdiff < 0 # left
        return 8
    end    
end

function arrow_offset(a, b)
    xdiff = b.x - a.x
    ydiff = b.y - a.y
    ofv = 25

    offsets = [
        (ofv, 0), (ofv, 0), (ofv, 0), (ofv, 0), (ofv, 0), (ofv, 0), (0, -ofv), (0, -ofv)
    ]
    return offsets[get_direction_index(xdiff, ydiff)]
end

function get_direction_offset(a, b, r)
    xdiff = b.x - a.x
    ydiff = b.y - a.y

    sr = sqrt(2) / 2 * r
    offsets = [
        (sr, sr), (-sr, -sr), (sr, -sr), (-sr, sr), (0, r), (0, -r), (r, 0), (-r, 0)
    ]
    return offsets[get_direction_index(xdiff, ydiff)]
end

function print_frontier(ds)
    if isempty(ds)
        return "[ ]"
    else
        io = IOBuffer()
        write(io, "[")
        count = 1
        for pair in sort(collect(ds), by=x->x.second)
            v, d_v = pair
            if d_v == inf
                d_v = "∞"
            end
            if count == length(ds)
                write(io, "($v, $d_v)")
            else
                write(io, "($v, $d_v), ")
            end
            count += 1
        end
        write(io, "]")
        s = String(take!(io))
        close(io)
        return s
    end
end

const orange = (255, 165, 0) ./ 255
const blue = (0, 0, 255) ./ 255
const grey = (84, 84, 84) ./ 255
const purple = (160, 32, 240) ./ 255
const inf = 2^32 - 1

function dijkstra(gif::Bool=true)
    num_frames = 950
    radius = 40

    vertex_data = [
        (-300, -300, 1), (-300, 0, 2), (-300, 300, 3), (300, 300, 4), (300, -300, 5),
        (300, 0, 6), (0, 0, 7)
    ]
    edges = [ # (u, v, d)
        (1, 2, 1), (1, 5, 3), (1, 7, 15), (2, 3, 2), (3, 4, 3),
        (4, 6, 4), (5, 6, 8), (5, 7, 9), (6, 7, 1)
    ]
    graph = [Vector{Tuple{Int, Int, Int}}() for _ in 1:V]
    for e in edges
        u, v, d = e
        push!(graph[u], tuple(u, v, d))
    end
    
    video = Video(1000, 1000)
    Background(1:num_frames, ground)

    source = 1
    vertices = Object[]
    distances = Object[]

    for vert in vertex_data
        x, y, v_no = vert
        circle_center = Object((args...) -> make_circle(x, y, radius, :fill))
        Object((args...) -> make_text(25, "$v_no", pos(circle_center) + Point(0, -10), "black"))
        if vert[3] == source
            dist_text = Object((args...; text="0") -> 
                make_text(30, text, pos(circle_center) + Point(0, 20), "black"))
        else
            dist_text = Object((args...; text="∞") -> 
                make_text(30, text, pos(circle_center) + Point(0, 20), "black"))
        end
        push!(vertices, circle_center)
        push!(distances, dist_text)
    end

    for edge in edges
        u, v, d = edge
        u_pos, v_pos = vertices[u], vertices[v]
        arrow_midpoint = Object((args...) -> make_arrow(pos(u_pos), pos(v_pos), radius))
        Object((args...) -> make_text(25, "$d", pos(arrow_midpoint) + arrow_offset(pos(u_pos), pos(v_pos)), "black"))
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

    orange_to_purple = Animation(
        [0, 1],
        [RGB(orange...), RGB(purple...)],
        [sineio()],
    )

    purple_to_orange = Animation(
        [0, 1],
        [RGB(purple...), RGB(orange...)],
        [sineio()],
    )

    fno = 30

    pq = PriorityQueue{Int, Int}()
    dist = fill(inf, length(graph))
    prev = fill(-1, length(graph))
    dist[source] = 0

    queue_text = Object((args...; text=print_frontier(pq)) -> 
        make_text(25, "PQ: $text", Point(0, -400), "black")
    )

    for i in 1:length(graph)
        push!(pq, i => dist[i])
    end

    act!(queue_text, Action(fno:fno+15, change(:text, print_frontier(pq))))
    fno += 15

    while !isempty(pq)
        u, d_u = dequeue_pair!(pq)
        act!(queue_text, Action(fno:fno+15, change(:text, print_frontier(pq))))
        fno += 15
        act!(vertices[u], Action(fno:fno+15, orange_to_blue, sethue()))
        fno += 15
        for edge in graph[u]
            _, v, length_uv = edge
            alt = d_u + length_uv
            if alt < dist[v]
                dist[v] = alt
                prev[v] = u
                pq[v] = alt

                act!(vertices[v], Action(fno:fno+15, orange_to_purple, sethue()))
                fno += 15
                act!(distances[v], Action(fno:fno+15, change(:text, "$(dist[v])")))
                fno += 15
                act!(queue_text, Action(fno:fno+15, change(:text, print_frontier(pq))))
                fno += 15
                act!(vertices[v], Action(fno:fno+15, purple_to_orange, sethue()))
                fno += 15
            end
        end
        act!(vertices[u], Action(fno:fno+15, blue_to_grey, sethue()))
        fno += 15
    end

    render(
        video;
        pathname = if gif "dijkstra.gif" else "dijkstra.mp4" end,
        framerate = 30
    )
    return fno
end

dijkstra()
dijkstra(false)
