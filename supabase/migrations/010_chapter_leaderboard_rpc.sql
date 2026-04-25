-- Create a function to get chapter-specific leaderboard (top 5 players)
CREATE OR REPLACE FUNCTION get_chapter_leaderboard(chapter_id_param UUID)
RETURNS TABLE (
    username TEXT,
    avatar_url TEXT,
    total_chapter_xp BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.username, 
        p.avatar_url, 
        COALESCE(SUM(pp.xp_earned), 0)::BIGINT as total_chapter_xp
    FROM player_progress pp
    INNER JOIN puzzles pz ON pp.puzzle_id = pz.id
    INNER JOIN profiles p ON pp.user_id = p.id
    WHERE pz.chapter_id = chapter_id_param 
      AND pp.completed = true
    GROUP BY p.id, p.username, p.avatar_url
    ORDER BY total_chapter_xp DESC
    LIMIT 5;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
