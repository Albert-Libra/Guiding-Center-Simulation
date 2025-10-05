function data = read_wave(filename)
% READ_WAVE Read wave configuration (.wtor/.wpol) parameters into a struct.
%   data = read_wave(filename)
%
% Supports the project config layout (both .wpol and .wtor):
%   1: E0                (mV/m)
%   2: T                 (s, period)
%   3: omega_width       (-)
%   4: m                 (azimuthal mode number)
%   5: n                 (standing-wave harmonic)
%   6: sigma             (Gaussian sigma)
%   7: N                 (number of individual waves)
%   8: dmu               (step for numerical diff)
%   9: dL                (step for numerical diff)
%  10: phi0              (rad)
%  11: seed              (may be numeric or the literal 'seed')
%
% Lines can start with '#' (comment) and/or contain a trailing comment after ';'.
% Returns a struct with parsed fields and derived omega = 2*pi/T when T>0.

arguments
	filename (1,:) char
end

if ~exist(filename, 'file')
	error('read_wave:notFound', 'Config file not found: %s', filename);
end

fid = fopen(filename, 'r');
if fid == -1
	error('read_wave:openFail', 'Cannot open file: %s', filename);
end
cleanup = onCleanup(@() fclose(fid));

% Initialize with NaN/empty defaults
data = struct( ...
	'path', string(filename), ...
	'type', infer_type_(filename), ...
	'E0', NaN, ...
	'T', NaN, ...
	'omega_width', NaN, ...
	'm', NaN, ...
	'n', NaN, ...
	'sigma', NaN, ...
	'N', NaN, ...
	'dmu', NaN, ...
	'dL', NaN, ...
	'phi0', NaN, ...
	'seed', NaN, ...
	'seed_str', string.empty, ...
	'omega', NaN);

paramIndex = 0;
while true
	ln = fgetl(fid);
	if ~ischar(ln), break; end

	% Strip potential UTF-8/UTF-16 BOM or zero-width no-break space
	ln = local_strip_bom_(ln);
	ln = strtrim(ln);
	if isempty(ln) || startsWith(ln, '#')
		continue; % skip blanks and full-line comments
	end

	% Remove trailing segment starting from first ';'
	sc = strfind(ln, ';');
	if ~isempty(sc)
		ln = strtrim(ln(1:sc(1)-1));
	end
	if isempty(ln)
		continue;
	end

	% Attempt numeric parse; tolerate leading numeric token then text
	val = str2double(ln);
	if isnan(val)
		tok = regexp(ln, '^([-+]?\d*\.?\d+(?:[eE][-+]?\d+)?)', 'tokens', 'once');
		if ~isempty(tok)
			val = str2double(tok{1});
		end
	end

	paramIndex = paramIndex + 1;
	switch paramIndex
		case 1,  data.E0 = val;
		case 2,  data.T = val;
		case 3,  data.omega_width = val;
		case 4,  data.m = val;
		case 5,  data.n = val;
		case 6,  data.sigma = val;
		case 7,  data.N = val;
		case 8,  data.dmu = val;
		case 9,  data.dL = val;
		case 10, data.phi0 = val;
		case 11
			% Seed: may be numeric or a literal like 'seed'
			if ~isnan(val)
				data.seed = val;
				data.seed_str = string(num2str(val));
			else
				data.seed = NaN;
				data.seed_str = string(strtrim(ln));
			end
		otherwise
			% ignore extra lines
	end
end

% Derived omega if T is valid
if isfinite(data.T) && data.T > 0
	data.omega = 2*pi/data.T;
end

end % function

% --------- helpers ---------
function tp = infer_type_(fname)
[~,~,ext] = fileparts(fname);
ext = lower(strrep(ext,'.','')); % remove dot
if any(strcmp(ext, {'wtor','wpol'}))
	tp = string(ext);
else
	tp = string('unknown');
end
end

function s = local_strip_bom_(s)
% Remove common BOM/ZWNBSP characters that may appear at line start
if isempty(s), return; end
% UTF-8 BOM as char(65279) can appear in MATLAB char vector
if s(1) == char(65279)
	s = s(2:end);
end
% Also try to detect if the string begins with the textual BOM bytes
if strncmp(s, char([239 187 191]), 1)
	s = s(4:end); % be conservative
end
end