using Javis, Colors

function ground(args...)
    background("black")
    sethue("white")
end

# From cormullion/hilbert-animation.jl at: https://gist.github.com/cormullion/40cca8cc3ad7a315fe2f943dbe832797
function hilbert_helper(
    pointslist::Array{Point,1},
    start::Point,
    unitx::Point,
    unity::Point,
    depth,
)
    if depth <= 0
        push!(
            pointslist,
            Point(start.x + (unitx.x + unity.x) / 2, start.y + (unitx.y + unity.y) / 2),
        )
    else
        hilbert_helper(
            pointslist,
            start,
            Point(unity.x / 2, unity.y / 2),
            Point(unitx.x / 2, unitx.y / 2),
            depth - 1,
        )
        hilbert_helper(
            pointslist,
            Point(start.x + unitx.x / 2, start.y + unitx.y / 2),
            Point(unitx.x / 2, unitx.y / 2),
            Point(unity.x / 2, unity.y / 2),
            depth - 1,
        )
        hilbert_helper(
            pointslist,
            Point(start.x + unitx.x / 2 + unity.x / 2, start.y + unitx.y / 2 + unity.y / 2),
            Point(unitx.x / 2, unitx.y / 2),
            Point(unity.x / 2, unity.y / 2),
            depth - 1,
        )
        hilbert_helper(
            pointslist,
            Point(start.x + unitx.x / 2 + unity.x, start.y + unitx.y / 2 + unity.y),
            Point(-unity.x / 2, -unity.y / 2),
            Point(-unitx.x / 2, -unitx.y / 2),
            depth - 1,
        )
    end
    return pointslist
end

function hilbert_alt(gif::Bool = true)
    num_frames = 260
    video = Video(400, 400)
    Background(1:num_frames, ground)

    hilbertcurve = hilbert_helper(Point[], O - (128, 128), Point(256, 0), Point(0, 256), 5)
    n = length(hilbertcurve) ÷ 4
    pts = Matrix{Union{Missing, Point}}(missing, 4, n)
    start = 1
    stop = n
    for i in 1:4
        pts[i, :] = hilbertcurve[start:stop]
        start, stop = stop + 1, stop + n
    end

    colorants = [colorant"red", colorant"green", colorant"purple", colorant"blue"]
    colors = [range(colorants[i], colorants[mod1(i + 1, length(colorants)) ], length = n) for i in 1:4]

    fno = 2
    for i = 2:n
        for j = 1:4
            prev = pts[j, i-1]
            next = pts[j, i]
            diff = next - prev
            Object(fno:num_frames, JLine(prev, next; color = colors[j][i]))
            Object(fno:num_frames, JLine(prev, next; color="white"))
        end
        fno += 1
    end

    render(video; pathname = if gif
        "hilbert_alt.gif"
    else
        "hilbert_alt.mp4"
    end, framerate = 30)
    return fno
end

hilbert_alt()
hilbert_alt(false)
